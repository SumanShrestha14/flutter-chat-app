import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

class BlockedUserPage extends StatefulWidget {
  const BlockedUserPage({super.key});

  @override
  State<BlockedUserPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  // chat and auth service
  final AuthService authService = AuthService();
  final ChatServices chatServices = ChatServices();
  String userID = AuthService().getCurrentUser()!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blocked Users")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatServices.getBlockedUserStream(auth.getCurrentUser()),
        builder: builder,
      ),
    );
  }
}
