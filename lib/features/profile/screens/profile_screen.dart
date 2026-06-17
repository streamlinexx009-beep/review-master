import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(),
            title: Text('Student Name'),
            subtitle: Text('student@email.com'),
          ),
        ],
      ),
    );
  }
}