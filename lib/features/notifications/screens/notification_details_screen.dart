import 'package:flutter/material.dart';

class NotificationDetailsScreen
    extends StatelessWidget {

  const NotificationDetailsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Notification',
        ),
      ),
      body: const Center(
        child: Text(
          'Notification Details',
        ),
      ),
    );
  }
}