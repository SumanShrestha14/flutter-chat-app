import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ChatServices chatServices = ChatServices();

  final AuthService authService = AuthService();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    // if there is something in textField and button is clicked

    if (messageController.text.isNotEmpty) {
      try {
        await chatServices.sendMessage(
          widget.receiverID,
          messageController.text,
        );
        messageController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send message: ${e.toString()}"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          // display messages
          // user message text field
        ],
      ),
    );
  }
}
