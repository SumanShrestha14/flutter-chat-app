import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  final TextEditingController messageController = TextEditingController();

  final ChatServices chatServices = ChatServices();
  final AuthService authService = AuthService();

  void sendMessage() async {
    // if there is something in textField and button is clicked

    if (messageController.text.isNotEmpty) {
      await chatServices.sendMessage(receiverID, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail)),
      body: Column(
        children: [
          // display messages
          // user message text field
        ],
      ),
    );
  }
}
