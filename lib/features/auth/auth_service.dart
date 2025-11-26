import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instace of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login
  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  Future<void> logout() async {
    return await _auth.signOut();
  }
}
