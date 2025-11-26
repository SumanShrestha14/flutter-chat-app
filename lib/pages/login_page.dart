import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_input_field.dart';

class LoginPage extends StatelessWidget {
  TextEditingController? emailController;
  TextEditingController? passwordController;
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  // login method
  void login() {}

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
              onTap: onTap,
              child: Text("Don't have an accout? Register now"),
            ),
          ],
        ),
      ),
    );
  }
}
