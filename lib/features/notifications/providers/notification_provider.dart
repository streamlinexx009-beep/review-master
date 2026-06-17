import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_repository.dart';
import '../data/notification_repository_impl.dart';
import '../models/notification_model.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>(
  (ref) {
    return NotificationRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final notificationsProvider =
    FutureProvider<
        List<NotificationModel>>(
  (ref) {
    return ref
        .read(
          notificationRepositoryProvider,
        )
        .getNotifications();
  },
);