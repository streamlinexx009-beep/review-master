class TopicMasteryModel {
  final String topicName;
  final double mastery;

  final double flashcardMastery;
  final double practiceMastery;
  final double quizMastery;
  final double examMastery;

  const TopicMasteryModel({
    required this.topicName,
    required this.mastery,
    required this.flashcardMastery,
    required this.practiceMastery,
    required this.quizMastery,
    required this.examMastery,
  });

  factory TopicMasteryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TopicMasteryModel(
      topicName: map['topic_name'] ?? '',

      mastery:
          (map['overall_mastery'] as num?)
              ?.toDouble() ??
          0,

      flashcardMastery:
          (map['flashcard_mastery'] as num?)
              ?.toDouble() ??
          0,

      practiceMastery:
          (map['practice_mastery'] as num?)
              ?.toDouble() ??
          0,

      quizMastery:
          (map['quiz_mastery'] as num?)
              ?.toDouble() ??
          0,

      examMastery:
          (map['exam_mastery'] as num?)
              ?.toDouble() ??
          0,
    );
  }
}