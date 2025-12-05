import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/chat_bubble.dart';
import 'package:flutter_chat_app/components/custom_input_field.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';
import 'package:flutter_chat_app/features/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ChatServices chatServices = ChatServices();
  final AuthService authService = AuthService();

  // for textfield focus
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // cause a delay so that keyboard has time to show up
        // then the amount of remaining space will be calculates
        // then scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
        // wait a bit for listview to build  then scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  final ScrollController scrollController = ScrollController();
  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    // if there is something in textField and button is clicked

    if (messageController.text.trim().isNotEmpty) {
      try {
        await chatServices.sendMessage(
          widget.receiverID,
          messageController.text.trim(),
        );
        if (!mounted) return;
        scrollDown();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          // display messages
          Expanded(child: buildMessageList()),
          // user message text field
          buildUserInput(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    final currentUser = authService.getCurrentUser();
    if (currentUser == null) {
      return const Center(child: Text("User not authenticated"));
    }
    String senderID = currentUser.uid;
    return StreamBuilder(
      stream: chatServices.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }
        return ListView(
          controller: scrollController,
          children: snapshot.data!.docs
              .map((doc) => buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // if current user display message send by user on right side else left

    bool isCurrentUser = data["senderID"] == authService.getCurrentUser()!.uid;
    final currentUser = authService.getCurrentUser();
    if (currentUser == null) {
      return const SizedBox.shrink(); // Skip rendering if no user
    }

    // Validate message field
    final message = data["message"];
    if (message == null || message is! String) {
      return const SizedBox.shrink(); // Skip malformed messages
    }

    var alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [ChatBubble(message: message, isCurrentUser: isCurrentUser)],
      ),
    );
  }

  Widget buildUserInput() {
    return Row(
      children: [
        // text field to write message
        Expanded(
          child: CustomInputField(
            focusNode: focusNode,
            hintText: "Write a message...",
            isObscureText: false,
            controller: messageController,
          ),
        ),
        // send button
        Container(
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          margin: EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send_rounded),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
