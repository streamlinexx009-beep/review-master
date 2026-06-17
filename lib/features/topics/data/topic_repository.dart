import '../models/topic_model.dart';

abstract class TopicRepository {
  Future<List<TopicModel>> getTopicsBySubject(
    String subjectId,
  );

  Future<TopicModel?> getTopicById(
    String id,
  );

  Future<void> createTopic({
    required String subjectId,
    required String name,
    String? description,
  });

  Future<void> updateTopic(
    TopicModel topic,
  );

  Future<void> deleteTopic(
    String topicId,
  );
}