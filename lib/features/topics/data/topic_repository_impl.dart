import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/topic_model.dart';
import 'topic_repository.dart';

class TopicRepositoryImpl
    implements TopicRepository {
  final SupabaseClient client;

  TopicRepositoryImpl(
    this.client,
  );

  @override
  Future<List<TopicModel>>
      getTopicsBySubject(
    String subjectId,
  ) async {
    final data =
        await client
            .from('topics')
            .select()
            .eq(
              'subject_id',
              subjectId,
            )
            .order('name');

    return data
        .map<TopicModel>(
          (e) => TopicModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<TopicModel?> getTopicById(
    String id,
  ) async {
    final data =
        await client
            .from('topics')
            .select()
            .eq('id', id)
            .maybeSingle();

    if (data == null) {
      return null;
    }

    return TopicModel.fromMap(data);
  }

  @override
  Future<void> createTopic({
    required String subjectId,
    required String name,
    String? description,
  }) async {
    await client
        .from('topics')
        .insert({
      'subject_id': subjectId,
      'name': name,
      'description': description,
    });
  }

  @override
  Future<void> updateTopic(
    TopicModel topic,
  ) async {
    await client
        .from('topics')
        .update(topic.toMap())
        .eq('id', topic.id);
  }

  @override
  Future<void> deleteTopic(
    String topicId,
  ) async {
    await client
        .from('topics')
        .delete()
        .eq('id', topicId);
  }
}