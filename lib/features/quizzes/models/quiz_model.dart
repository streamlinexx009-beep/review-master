class QuizModel {

  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String? topicId;
  final int passingScore;
  final int timeLimit;
  final bool isPublished;

  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.passingScore,
    required this.timeLimit,
    required this.isPublished,
    this.topicId,
  });

  factory QuizModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return QuizModel(
      id: map['id'],
      title: map['title'],
      description:
          map['description'] ?? '',
      subjectId:
          map['subject_id'],
      topicId:
          map['topic_id'],
      passingScore:
          map['passing_score'],
      timeLimit:
          map['time_limit'],
      isPublished:
          map['is_published'],
    );
  }
}