import 'package:flutter/material.dart';

class ExamTimerWidget
    extends StatelessWidget {

  final int remainingMinutes;

  const ExamTimerWidget({
    super.key,
    required this.remainingMinutes,
  });

  @override
  Widget build(BuildContext context) {

    return Chip(
      label:
          Text(
        '$remainingMinutes min',
      ),
    );
  }
}