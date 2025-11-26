import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void logout() {
    final _auth = AuthService();
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),
    );
  }
}
