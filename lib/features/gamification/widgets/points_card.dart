import 'package:flutter/material.dart';

class PointsCard
    extends StatelessWidget {

  final int points;

  const PointsCard({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title:
            const Text(
          'Points',
        ),
        subtitle:
            Text(
          points.toString(),
        ),
      ),
    );
  }
}