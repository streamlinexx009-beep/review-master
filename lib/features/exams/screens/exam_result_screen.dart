import 'package:flutter/material.dart';

class ExamResultScreen
    extends StatelessWidget {

  const ExamResultScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Exam Result',
        ),
      ),
    );
  }
}