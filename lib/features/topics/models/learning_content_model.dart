class LearningContentModel {
  final String id;
  final String topicId;
  final String title;
  final String content;

  const LearningContentModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.content,
  });

  factory LearningContentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return LearningContentModel(
      id: map['id'].toString(),
      topicId: map['topic_id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'content': content,
    };
  }
}