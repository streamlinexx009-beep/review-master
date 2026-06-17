import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/topic_summary_repository.dart';
import '../data/topic_summary_repository_impl.dart';
import '../models/topic_summary_model.dart';

final topicSummaryRepositoryProvider =
    Provider<TopicSummaryRepository>(
  (ref) {
    return TopicSummaryRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final topicSummaryProvider =
    FutureProvider.family<
        TopicSummaryModel?,
        String>(
  (
    ref,
    topicId,
  ) {
    return ref
        .read(
          topicSummaryRepositoryProvider,
        )
        .getSummary(
          topicId,
        );
  },
);