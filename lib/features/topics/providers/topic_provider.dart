import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/topic_repository.dart';
import '../data/topic_repository_impl.dart';
import '../models/topic_model.dart';

final topicRepositoryProvider =
    Provider<TopicRepository>(
  (ref) {
    return TopicRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final topicsProvider =
    FutureProvider.family<
        List<TopicModel>,
        String>(
  (
    ref,
    subjectId,
  ) async {
    return ref
        .read(
          topicRepositoryProvider,
        )
        .getTopicsBySubject(
          subjectId,
        );
  },
);

final topicProvider =
    FutureProvider.family<
        TopicModel?,
        String>(
  (
    ref,
    topicId,
  ) async {
    return ref
        .read(
          topicRepositoryProvider,
        )
        .getTopicById(
          topicId,
        );
  },
);