import '../models/topic_summary_model.dart';

abstract class TopicSummaryRepository {
  Future<TopicSummaryModel?> getSummary(
    String topicId,
  );
}