import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/topic_model.dart';
import 'topic_repository.dart';

class TopicRepositoryImpl implements TopicRepository {
  final SupabaseClient client;

  TopicRepositoryImpl(this.client);

  @override
  Future<List<TopicModel>> getTopicsBySubject(String subjectId) async {
    final data = await client
        .from('topics')
        .select()
        .eq('subject_id', subjectId)
        .eq('is_active', true)
        .order('display_order')
        .order('name');

    return data.map<TopicModel>((e) => TopicModel.fromMap(e)).toList();
  }

  @override
  Future<TopicModel?> getTopicById(String id) async {
    final data = await client
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
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await client.from('topics').insert({
      'subject_id': subjectId,
      'name': name.trim(),
      'description': description?.trim(),
    });
  }

  @override
  Future<void> updateTopic(TopicModel topic) async {
    await client.from('topics').update({
      'subject_id': topic.subjectId,
      'name': topic.name.trim(),
      'description': topic.description?.trim(),
      'display_order': topic.displayOrder,
      'is_active': topic.isActive,
    }).eq('id', topic.id);
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await client.from('topics').update({'is_active': false}).eq('id', topicId);
  }
}
