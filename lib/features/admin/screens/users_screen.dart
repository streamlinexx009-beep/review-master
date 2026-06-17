import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('John Doe'),
            subtitle: Text('Student'),
          ),
        ],
      ),
    );
  }
}