import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/topic_mastery_service.dart';

final topicMasteryProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, topicId) async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return TopicMasteryService().getTopicMastery(
      studentId: user.id,
      topicId: topicId,
    );
  },
);