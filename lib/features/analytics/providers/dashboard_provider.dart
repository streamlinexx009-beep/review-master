import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/analytics_service.dart';

final dashboardProvider =
    FutureProvider<Map<String, dynamic>>(
  (ref) async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('Not logged in');
    }

    return AnalyticsService()
        .getDashboardData(user.id);
  },
);