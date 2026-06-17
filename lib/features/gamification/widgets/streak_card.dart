import 'package:flutter/material.dart';

class StreakCard
    extends StatelessWidget {

  final int streak;

  const StreakCard({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title:
            const Text(
          'Study Streak',
        ),
        subtitle:
            Text(
          '$streak Days',
        ),
      ),
    );
  }
}