class FlashcardFavoriteModel {

  final String id;

  final String studentId;

  final String flashcardId;

  const FlashcardFavoriteModel({
    required this.id,
    required this.studentId,
    required this.flashcardId,
  });

  factory FlashcardFavoriteModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return FlashcardFavoriteModel(
      id: map['id'],
      studentId: map['student_id'],
      flashcardId: map['flashcard_id'],
    );
  }
}