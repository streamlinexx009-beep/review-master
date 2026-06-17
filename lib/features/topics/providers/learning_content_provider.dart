import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/learning_content_repository.dart';
import '../data/learning_content_repository_impl.dart';
import '../models/learning_content_model.dart';

final learningContentRepositoryProvider =
    Provider<LearningContentRepository>(
  (ref) {
    return LearningContentRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final learningContentsProvider =
    FutureProvider.family<
        List<LearningContentModel>,
        String>(
  (
    ref,
    topicId,
  ) async {
    return ref
        .read(
          learningContentRepositoryProvider,
        )
        .getContentsByTopic(
          topicId,
        );
  },
);