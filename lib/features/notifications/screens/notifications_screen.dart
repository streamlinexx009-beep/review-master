import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen
    extends ConsumerWidget {

  const NotificationsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final notifications =
        ref.watch(
      notificationsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Notifications',
        ),
      ),

      body: notifications.when(
        data: (items) {

          return ListView.builder(
            itemCount:
                items.length,

            itemBuilder:
                (_, index) {

              final item =
                  items[index];

              return NotificationTile(
                title:
                    item.title,
                message:
                    item.message,
                isRead:
                    item.isRead,
              );
            },
          );
        },

        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (e, _) =>
            Center(
          child:
              Text(e.toString()),
        ),
      ),
    );
  }
}