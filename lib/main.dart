import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/features/auth/auth_gate.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/pages/chat_page.dart';
import 'package:flutter_chat_app/services/message_notification_listener.dart';
import 'package:flutter_chat_app/services/notification_service.dart';
import 'package:flutter_chat_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Set up notification tap handler
  notificationService.setNotificationTapCallback((payload) {
    if (payload != null) {
      // Payload format: "senderId|senderEmail"
      final parts = payload.split('|');
      if (parts.length == 2) {
        final senderId = parts[0];
        final senderEmail = parts[1];

        // Navigate to chat with the sender
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(receiverEmail: senderEmail, receiverID: senderId),
          ),
        );
      }
    }
  });

  // Start listening for messages when user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // User already authenticated, start listening immediately
    debugPrint('User already authenticated, starting message listener');
    MessageNotificationListener().startListening();
  }

  // Also listen for auth state changes
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      debugPrint('User authenticated, starting message listener');
      MessageNotificationListener().startListening();
    } else {
      debugPrint('User logged out, stopping message listener');
      MessageNotificationListener().stopListening();
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Chat App",
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
