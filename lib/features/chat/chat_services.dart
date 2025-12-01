import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  // Firestore
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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
}
