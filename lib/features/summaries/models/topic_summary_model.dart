class TopicSummaryModel {
  final String id;
  final String topicId;
  final String content;

  const TopicSummaryModel({
    required this.id,
    required this.topicId,
    required this.content,
  });

  factory TopicSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TopicSummaryModel(
      id: map['id'],
      topicId: map['topic_id'],
      content: map['content'],
    );
  }
}