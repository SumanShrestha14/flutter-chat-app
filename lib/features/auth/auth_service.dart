import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instace of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // login
  Future<UserCredential> login(String email, String password) async {
    // try {
    //   UserCredential userCredential = await _auth.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    //   return userCredential;
    // } on FirebaseAuthException catch (e) {
    //   throw Exception(e.code);
    // }
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // register
  Future<UserCredential> register(String email, String password) async {
    // try {
    //   return userCredential;
    // } on FirebaseAuthException catch (e) {
    //   throw Exception(e.code);
    // }

    // sign in user
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // save user info if it doesn't exists already
    _firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
    });
    return userCredential;
  }

  // logout
  Future<void> logout() async {
    return await _auth.signOut();
  }
}
