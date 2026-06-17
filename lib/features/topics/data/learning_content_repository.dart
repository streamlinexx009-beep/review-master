import '../models/learning_content_model.dart';

abstract class LearningContentRepository {
  Future<List<LearningContentModel>>
      getContentsByTopic(
    String topicId,
  );

  Future<void> createContent({
    required String topicId,
    required String title,
    required String content,
  });
}