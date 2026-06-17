import 'package:flutter/material.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Mock Board Exam'),
            subtitle: Text('100 Questions'),
          ),
        ],
      ),
    );
  }
}