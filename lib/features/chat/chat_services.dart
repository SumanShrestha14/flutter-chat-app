import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  // Firestore
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firebaseFirestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }
}
