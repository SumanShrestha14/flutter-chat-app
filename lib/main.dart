import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/login_or_register.dart';
import 'package:flutter_chat_app/pages/login_page.dart';
import 'package:flutter_chat_app/pages/register_page.dart';
import 'package:flutter_chat_app/theme/light_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat App",
      home: const LoginOrRegister(),
      theme: lightMode,
    );
  }
}
