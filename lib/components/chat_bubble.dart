import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 2.5, right: 10, left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isCurrentUser ? Colors.blue : Colors.grey.shade500,
      ),
      child: Text(message, style: const TextStyle(color: Colors.white)),
    );
  }
}
