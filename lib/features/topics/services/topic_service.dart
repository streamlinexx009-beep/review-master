import '../models/topic_model.dart';

class TopicService {
  static final List<TopicModel> _topics = [];

  List<TopicModel> getTopicsBySubject(
    String subjectId,
  ) {
    return _topics
        .where(
          (t) => t.subjectId == subjectId,
        )
        .toList();
  }

  void addTopic(
    TopicModel topic,
  ) {
    _topics.add(topic);
  }
}