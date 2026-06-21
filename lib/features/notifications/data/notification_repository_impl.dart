import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient client;

  NotificationRepositoryImpl(this.client);

  User _requireUser() {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return user;
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final user = _requireUser();

    final data = await client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return data.map<NotificationModel>((e) => NotificationModel.fromMap(e)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    _requireUser();

    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    final user = _requireUser();

    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id);
  }
}
