import 'package:flutter/material.dart';

class StudyPlansScreen extends StatelessWidget {
  const StudyPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plans'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('NCLEX Review Plan'),
            subtitle: Text('In Progress'),
          ),
        ],
      ),
    );
  }
}