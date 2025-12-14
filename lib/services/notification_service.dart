import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");

  // Show local notification for background messages
  final notificationService = NotificationService();
  await notificationService.showLocalNotification(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool initialized = false;
  // Initialize notification service
  Future<void> initialize() async {
    if (initialized) {
      return;
    }

    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM User granted permission: ${settings.authorizationStatus}');

    // Request Android 13+ notification permissions
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');
      }
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for incoming chat messages',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // You can save this token to Firestore for sending targeted notifications
    });

    initialized = true;
  }

  // Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');

    // Show local notification for foreground messages
    await showLocalNotification(message);
  }

  // Show local notification
  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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

    // Use message ID as notification ID, or use a hash of sender ID
    int notificationId = message.hashCode.abs();

    // Build payload in same format as MessageNotificationListener: "senderId|senderEmail"
    final senderId = message.data['senderId'] ?? '';
    final senderEmail = message.data['senderEmail'] ?? '';
    final payload = '$senderId|$senderEmail';

    await _localNotifications.show(
      notificationId,
      notification.title ?? 'New Message',
      notification.body ?? '',
      details,
      payload: payload,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigation will be handled via a callback
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(response.payload);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.messageId}');
    // Extract sender info from message data and navigate to chat
    final data = message.data;
    if (data.containsKey('senderId') &&
        data.containsKey('senderEmail') &&
        _onNotificationTapCallback != null) {
      final payload = '${data['senderId']}|${data['senderEmail']}';
      _onNotificationTapCallback!(payload);
    }
  }

  // Callback for notification taps
  Function(String?)? _onNotificationTapCallback;

  void setNotificationTapCallback(Function(String?)? callback) {
    _onNotificationTapCallback = callback;
  }

  // Public method to show local notification (for use by message listener)
  FlutterLocalNotificationsPlugin get localNotifications => _localNotifications;

  // Get FCM token (to store in Firestore for targeting notifications)
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to a topic (optional)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic (optional)
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
