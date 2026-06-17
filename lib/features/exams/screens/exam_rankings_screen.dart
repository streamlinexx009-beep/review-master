import 'package:flutter/material.dart';

class ExamRankingsScreen
    extends StatelessWidget {

  const ExamRankingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Rankings',
        ),
      ),
    );
  }
}