import 'package:flutter/material.dart';

class AnalyticsCard
    extends StatelessWidget {

  final String title;
  final String value;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}