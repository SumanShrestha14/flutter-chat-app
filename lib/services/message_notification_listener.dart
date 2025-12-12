import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_chat_app/services/notification_service.dart';

class MessageNotificationListener {
  static final MessageNotificationListener _instance =
      MessageNotificationListener._internal();
  factory MessageNotificationListener() => _instance;
  MessageNotificationListener._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _messageSubscription;
  String? _currentChatUserId;
  Set<String> _processedMessageIds = {};
  Map<String, StreamSubscription> _chatRoomSubscriptions = {};
  Map<String, Timestamp?> _lastMessageTimestamps = {}; // Track last message per chat room

  // Start listening for new messages across all chats
  void startListening() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('[NotificationListener] No authenticated user, cannot listen for messages');
      return;
    }

    debugPrint('[NotificationListener] Starting to listen for messages for user: ${currentUser.uid}');
    _listenForIncomingMessages(currentUser.uid);
  }

  // Stop listening
  void stopListening() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    
    // Cancel all chat room subscriptions
    for (var subscription in _chatRoomSubscriptions.values) {
      subscription.cancel();
    }
    _chatRoomSubscriptions.clear();
    
    _processedMessageIds.clear();
  }

  // Set the current chat (to avoid showing notifications for current chat)
  void setCurrentChat(String? otherUserId) {
    _currentChatUserId = otherUserId;
  }

  // Listen for incoming messages from all chat rooms
  void _listenForIncomingMessages(String currentUserId) {
    // Listen to all chat rooms - we'll filter for ones containing current user
    _messageSubscription = _firestore
        .collection('chat_room')
        .snapshots()
        .listen((chatRoomsSnapshot) {
      final Set<String> activeChatRoomIds = {};

      // Process each chat room
      for (var chatRoomDoc in chatRoomsSnapshot.docs) {
        final chatRoomId = chatRoomDoc.id;
        final userIds = chatRoomId.split('_');

        // Check if current user is part of this chat room
        if (userIds.contains(currentUserId) && userIds.length == 2) {
          activeChatRoomIds.add(chatRoomId);
          
          // Get the other user ID
          final otherUserId =
              userIds.firstWhere((id) => id != currentUserId);

          // Only listen if we're not already listening to this chat room
          if (!_chatRoomSubscriptions.containsKey(chatRoomId)) {
            _listenToChatRoomMessages(chatRoomId, currentUserId, otherUserId);
          }
        }
      }

      // Remove subscriptions for chat rooms that no longer exist
      final toRemove = _chatRoomSubscriptions.keys
          .where((id) => !activeChatRoomIds.contains(id))
          .toList();
      for (var chatRoomId in toRemove) {
        _chatRoomSubscriptions[chatRoomId]?.cancel();
        _chatRoomSubscriptions.remove(chatRoomId);
      }
    }, onError: (error) {
      debugPrint('Error listening to chat rooms: $error');
    });
  }

  // Listen to messages in a specific chat room
  void _listenToChatRoomMessages(
    String chatRoomId,
    String currentUserId,
    String otherUserId,
  ) {
    debugPrint('[NotificationListener] Setting up listener for chat room: $chatRoomId');
    
    // Get the last known message timestamp for this chat room
    Timestamp? lastMessageTimestamp = _lastMessageTimestamps[chatRoomId];
    
    // Listen to all messages in this chat room, not just the latest
    // This ensures we catch new messages as they arrive
    final subscription = _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverID', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(5) // Get last 5 messages to handle edge cases
        .snapshots()
        .listen((messagesSnapshot) async {
      debugPrint('[NotificationListener] Received ${messagesSnapshot.docs.length} messages in $chatRoomId');
      
      if (messagesSnapshot.docs.isEmpty) {
        return;
      }

      // Process messages from newest to oldest
      for (var messageDoc in messagesSnapshot.docs) {
        final messageId = messageDoc.id;
        final messageData = messageDoc.data();
        final messageTimestamp = messageData['timestamp'] as Timestamp?;

        // Skip if message timestamp is null
        if (messageTimestamp == null) {
          continue;
        }

        // Skip if already processed
        if (_processedMessageIds.contains(messageId)) {
          continue;
        }

        // Skip if this is the same as last message we processed (no new message)
        if (lastMessageTimestamp != null) {
          final lastTs = lastMessageTimestamp;
          final currentTs = messageTimestamp;
          if (currentTs.seconds == lastTs.seconds &&
              currentTs.nanoseconds == lastTs.nanoseconds) {
            continue;
          }
          
          // Skip if this message is older than the last one we processed
          if (currentTs.compareTo(lastTs) <= 0) {
            continue;
          }
        }

        // Get sender info
        final senderId = messageData['senderID'];
        
        // Skip if sender is current user (shouldn't happen with receiverID filter, but check anyway)
        if (senderId == currentUserId) {
          continue;
        }

        // Skip if this is the current chat
        if (_currentChatUserId == senderId) {
          // Still update timestamp so we don't notify when leaving this chat
          _lastMessageTimestamps[chatRoomId] = messageTimestamp;
          _processedMessageIds.add(messageId);
          continue;
        }

        // This is a new message that should trigger a notification
        debugPrint('[NotificationListener] New message detected: $messageId from $senderId');
        
        // Update tracking
        _lastMessageTimestamps[chatRoomId] = messageTimestamp;
        _processedMessageIds.add(messageId);

        // Get sender email and message
        String senderEmail = messageData['senderEmail'] ?? 'Unknown';
        String message = messageData['message'] ?? 'New message';

        // Show notification
        await _showMessageNotification(
          senderEmail: senderEmail,
          message: message,
          senderId: senderId ?? '',
        );
        
        // Only process the newest message
        break;
      }
    }, onError: (error) {
      debugPrint('[NotificationListener] Error listening to messages in $chatRoomId: $error');
      // Try to get more details about the error
      if (error.toString().contains('index')) {
        debugPrint('[NotificationListener] Firestore index may be required. Check Firebase Console.');
      }
    });

    _chatRoomSubscriptions[chatRoomId] = subscription;
  }

  // Show notification for a new message
  Future<void> _showMessageNotification({
    required String senderEmail,
    required String message,
    required String senderId,
  }) async {
    debugPrint('[NotificationListener] Attempting to show notification for message from $senderEmail: $message');

    // Use the notification service's local notifications
    final localNotifications = _notificationService.localNotifications;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for incoming chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Pass sender info as JSON string: "senderId|senderEmail"
    final payload = '$senderId|$senderEmail';
    
    try {
      await localNotifications.show(
        senderId.hashCode.abs(), // Use sender ID hash as notification ID (absolute value)
        'New message from $senderEmail',
        message.length > 50 ? '${message.substring(0, 50)}...' : message,
        details,
        payload: payload, // Pass sender ID and email for navigation
      );
      debugPrint('[NotificationListener] Notification shown successfully for $senderEmail');
    } catch (e) {
      debugPrint('[NotificationListener] Error showing notification: $e');
    }
  }

  // Clear processed message IDs (call when user opens a chat)
  void clearProcessedMessages() {
    _processedMessageIds.clear();
  }
}
