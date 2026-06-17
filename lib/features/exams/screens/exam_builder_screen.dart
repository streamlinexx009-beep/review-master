import 'package:flutter/material.dart';

class ExamBuilderScreen
    extends StatelessWidget {

  const ExamBuilderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Exam Builder',
        ),
      ),
    );
  }
}