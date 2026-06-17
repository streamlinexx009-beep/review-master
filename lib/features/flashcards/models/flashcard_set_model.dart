class FlashcardSetModel {
  final String id;
  final String title;
  final String subjectId;

  const FlashcardSetModel({
    required this.id,
    required this.title,
    required this.subjectId,
  });

  factory FlashcardSetModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return FlashcardSetModel(
      id: map['id'],
      title: map['title'],
      subjectId: map['subject_id'],
    );
  }
}