import 'package:flutter/material.dart';

class ExamReviewScreen
    extends StatelessWidget {

  const ExamReviewScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Exam Review',
        ),
      ),
    );
  }
}