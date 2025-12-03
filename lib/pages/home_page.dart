import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_drawer.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';
import 'package:flutter_chat_app/pages/chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatServices chatService = ChatServices();
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home page")),
      drawer: CustomDrawer(),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error occurred!");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading....");
        }

        final users = snapshot.data ?? [];

        return ListView(
          children: users
              .map<Widget>((userData) => buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // individual tile
  Widget buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final email = userData["email"];
    final uid = userData["uid"];

    return UserTile(
      onTap: () {
        if (email is! String || email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot open chat: invalid user email"),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        if (uid is! String || uid.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot open chat: invalid user ID"),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                // ChatPage(receiverEmail: email, receiverID: userData["uid"]),
                ChatPage(receiverEmail: email, receiverID: uid),
          ),
        );
      },
      text: (email is String && email.isNotEmpty) ? email : "Anonymous",
    );
  }
}
