import 'package:flutter/material.dart';

class NotificationTile
    extends StatelessWidget {

  final String title;

  final String message;

  final bool isRead;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Icon(
        isRead
            ? Icons.notifications_none
            : Icons.notifications,
      ),
      title: Text(title),
      subtitle:
          Text(message),
    );
  }
}