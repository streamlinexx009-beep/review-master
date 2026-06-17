import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/learning_content_model.dart';
import 'learning_content_repository.dart';

class LearningContentRepositoryImpl
    implements LearningContentRepository {
  final SupabaseClient client;

  LearningContentRepositoryImpl(
    this.client,
  );

  @override
  Future<List<LearningContentModel>>
      getContentsByTopic(
    String topicId,
  ) async {
    final data =
        await client
            .from('learning_contents')
            .select()
            .eq(
              'topic_id',
              topicId,
            )
            .order('title');

    return data
        .map<LearningContentModel>(
          (e) =>
              LearningContentModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<void> createContent({
    required String topicId,
    required String title,
    required String content,
  }) async {
    await client
        .from('learning_contents')
        .insert({
      'topic_id': topicId,
      'title': title,
      'content': content,
    });
  }
}