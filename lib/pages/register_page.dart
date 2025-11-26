import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_input_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  // register method
  void register() {}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            Text("Let's create an account for you"),
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
            CustomInputField(
              hintText: "Confirm Password",
              isObscureText: true,
              controller: confirmPasswordController,
            ),
            // register button
            const SizedBox(height: 15),
            CustomButton(btnText: "Register", onTap: register),
            // register now
            const SizedBox(height: 15),
            GestureDetector(
              onTap: widget.onTap,
              child: Text("Already have an account? Login now"),
            ),
          ],
        ),
      ),
    );
  }
}
