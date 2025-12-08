import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String userID;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.userID,
  });

  // Show Options
  void showOptions(BuildContext context, String messageID, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // report message
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Report"),
                onTap: () {},
              ),
              // block user
              // cancel
            ],
          ),
        );
      },
    );
  }

  // report message

  // Block user

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // show options to report block and unblock
          showOptions(context, messageID, userID);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 2.5, right: 10, left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isCurrentUser ? Colors.blue : Colors.grey.shade800,
        ),
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
