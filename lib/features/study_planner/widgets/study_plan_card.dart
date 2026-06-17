import 'package:flutter/material.dart';

class StudyPlanCard
    extends StatelessWidget {

  final String title;

  final String status;

  const StudyPlanCard({
    super.key,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle:
            Text(status),
      ),
    );
  }
}