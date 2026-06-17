import 'package:flutter/material.dart';

class NotificationCard
    extends StatelessWidget {

  final String title;
  final String message;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.notifications,
        ),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}