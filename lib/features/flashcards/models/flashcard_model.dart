class FlashcardModel {
  final String id;
  final String subjectId;
  final String? topicId;
  final String frontText;
  final String backText;
  final String? createdBy;

  const FlashcardModel({
    required this.id,
    required this.subjectId,
    required this.frontText,
    required this.backText,
    this.createdBy,
    this.topicId,
  });

  factory FlashcardModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return FlashcardModel(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      topicId: map['topic_id'] as String?,
      frontText: map['front_text'] as String,
      backText: map['back_text'] as String,
      createdBy: map['created_by'] as String?,
    );
  }
}