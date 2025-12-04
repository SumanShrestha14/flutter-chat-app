import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instace of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // get current user

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // login
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // register
  Future<UserCredential> register(String email, String password) async {
    // sign in user
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Save user info to Firestore
    try {
      await _firebaseFirestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
          }, SetOptions(merge: true));
    } catch (e) {
      // Consider rolling back the user creation or logging the error
      await userCredential.user?.delete();
      throw Exception('Failed to save user data: $e');
    }
    return userCredential;
  }

  // logout
  Future<void> logout() async {
    return await _auth.signOut();
  }
}
