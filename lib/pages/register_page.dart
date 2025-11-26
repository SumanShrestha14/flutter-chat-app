import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_input_field.dart';

class RegisterPage extends StatelessWidget {
  TextEditingController? emailController;
  TextEditingController? passwordController;
  TextEditingController? confirmPasswordController;
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // register method
  void register() {}

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
              onTap: onTap,
              child: Text("Already have an account? Login now"),
            ),
          ],
        ),
      ),
    );
  }
}
