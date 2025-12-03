import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/models/message.dart';

class ChatServices {
  // Firestore and auth
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firebaseFirestore
        .collection("Users")
        .snapshots()
        .handleError((error) {
          // Log error or return empty list
          print('Error fetching users: $error');
        })
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return doc.data();
          }).toList();
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
}
