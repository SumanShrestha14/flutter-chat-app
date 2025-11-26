import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
        // actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),
      drawer: CustomDrawer(),
    );
  }
}
