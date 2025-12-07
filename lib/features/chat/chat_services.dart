import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/models/message.dart';

class ChatServices extends ChangeNotifier {
  // Firestore and auth
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get all user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firebaseFirestore
        .collection("Users")
        .snapshots()
        .handleError((error) {
          // Log error or return empty list
          debugPrint('Error fetching users: $error');
        })
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return doc.data();
          }).toList();
        });
  }

  // Get all user expect blocked users
  Stream<List<Map<String, dynamic>>> getUserStreamExceptBlockedUser() {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }
    return firebaseFirestore
        .collection('Users')
        .doc(currentUser.uid)
        .collection("BlockedUser")
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
          final userSnapShot = await firebaseFirestore
              .collection('Users')
              .get();
          return userSnapShot.docs
              .where((doc) => !blockedUserIds.contains(doc.id))
              .map((doc) => doc.data())
              .toList();
        });
  }

  // send message
  Future<void> sendMessage(String receiverID, String message) async {
    // get current logged in user
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    final String currentUserID = currentUser.uid;
    final String? currentUserEmail = currentUser.email;
    if (currentUserEmail == null) {
      throw Exception('User email not available');
    }
    final Timestamp timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );
    // construct a chat room ID
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    // add new message to database
    await firebaseFirestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // receive message

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return firebaseFirestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Report User
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    final report = {
      'reportedBy': currentUser.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timeStamp': FieldValue.serverTimestamp(),
    };

    await firebaseFirestore.collection("reports").add(report);
  }

  // Block User

  Future<void> blockUser(String userID) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }
    await firebaseFirestore
        .collection("Users")
        .doc(currentUser.uid)
        .collection("BlockedUser")
        .doc(userID)
        .set({});
    notifyListeners();
  }

  // Unblock User
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }
    await firebaseFirestore
        .collection("Users")
        .doc(currentUser.uid)
        .collection("BlockedUser")
        .doc(blockedUserId)
        .delete();
    notifyListeners();
  }

  // Get Blocked user
  Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userId) {
    return firebaseFirestore
        .collection("Users")
        .doc(userId)
        .collection("BlockedUser")
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
          final userDocs = await Future.wait(
            blockedUserIds.map(
              (id) => firebaseFirestore.collection("Users").doc(id).get(),
            ),
          );
          return userDocs
              .where((doc) => doc.exists)
              .map((doc) => doc.data()! as Map<String, dynamic>)
              .toList();
        });
  }
}
