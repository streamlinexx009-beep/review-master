import 'package:flutter/material.dart';

class StudyStreakScreen
    extends StatelessWidget {

  const StudyStreakScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Study Streak',
        ),
      ),
    );
  }
}