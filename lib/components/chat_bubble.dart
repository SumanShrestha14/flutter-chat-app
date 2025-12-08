import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

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

  void showOptions(BuildContext context, String messageID, String userID) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                reportMessage(context, messageID, userID);
              },
              isDestructiveAction: true,
              child: const Text("Report", style: TextStyle(fontSize: 16)),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                blockUser();
              },
              child: const Text("Block User", style: TextStyle(fontSize: 16)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
            isDefaultAction: true,
          ),
        );
      },
    );
  }

  void reportMessage(BuildContext context, String messageID, String userID) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report this message?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ChatServices().reportUser(messageID, userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("Report Successful"),
                ),
              );
            },
            child: Text("Report"),
          ),
        ],
      ),
    );
  }

  void blockUser() {
    // TODO : implement
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        debugPrint("Long Press");
        if (!isCurrentUser) {
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
