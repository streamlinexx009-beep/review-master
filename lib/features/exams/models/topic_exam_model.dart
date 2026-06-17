class TopicExamModel {
  final String id;
  final String topicId;
  final String title;

  TopicExamModel({
    required this.id,
    required this.topicId,
    required this.title,
  });

  factory TopicExamModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopicExamModel(
      id: json['id'],
      topicId: json['topic_id'],
      title: json['title'],
    );
  }
}