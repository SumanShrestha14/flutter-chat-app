import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

class BlockedUserPage extends StatelessWidget {
  BlockedUserPage({super.key});
  // chat and auth service
  final AuthService authService = AuthService();
  final ChatServices chatServices = ChatServices();

  @override
  Widget build(BuildContext context) {
    String userID = AuthService().getCurrentUser()!.uid;
    return Scaffold(
      appBar: AppBar(title: Text("Blocked Users")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatServices.getBlockedUserStream(userID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error occurred"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading ..."));
          }

          final blockedUser = snapshot.data ?? [];
          // if no users
          if (blockedUser.isEmpty) {
            return const Center(child: Text("Block list is empty.."));
          }

          return ListView.builder(
            itemCount: blockedUser.length,
            itemBuilder: (context, index) {
              final user = blockedUser[index];
              return UserTile(
                text: user["email"],
                onTap: () => showUnblockBox(context, user["uid"]),
              );
            },
          );
        },
      ),
    );
  }

  void showUnblockBox(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unblock user"),
        content: const Text("Are you sure you want to unblock this user"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                chatServices.unblockUser(userID);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Unblock Successful")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Unblock failed: $e")));
                }
              }
            },
            child: const Text("Unblock"),
          ),
        ], // cancel button
      ),
    );
  }
}
