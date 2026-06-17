import 'package:flutter/material.dart';

class AchievementCard
    extends StatelessWidget {

  final String title;

  final String description;

  final int points;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle:
            Text(description),
        trailing:
            Text('$points pts'),
      ),
    );
  }
}