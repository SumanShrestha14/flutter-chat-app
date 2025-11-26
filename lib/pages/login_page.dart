import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_input_field.dart';
import 'package:flutter_chat_app/features/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // login method
  void login() async {
    final authService = AuthService();
    // get user data
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      await authService.login(email, password);
    } catch (e) {
      if (!mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.pages_outlined,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            // welcome message
            const SizedBox(height: 10),
            Text("Welcome back! we missed you"),
            //  email text field
            const SizedBox(height: 20),
            CustomInputField(
              hintText: "Email",
              isObscureText: false,
              controller: emailController,
            ),
            // password text field
            const SizedBox(height: 10),
            CustomInputField(
              hintText: "Password",
              isObscureText: true,
              controller: passwordController,
            ),
            // login button
            const SizedBox(height: 15),
            CustomButton(btnText: "Login", onTap: login),
            // register now
            const SizedBox(height: 15),
            GestureDetector(
              onTap: widget.onTap,
              child: Text("Don't have an accout? Register now"),
            ),
          ],
        ),
      ),
    );
  }
}
