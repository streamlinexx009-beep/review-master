import '../models/flashcard_model.dart';
import 'package:flutter/foundation.dart';
abstract class FlashcardRepository {

  Future<List<FlashcardModel>>
    getFlashcards({
      String? topicId,
    });

  Future<void> createFlashcard({
    required String subjectId,
    String? topicId,
    required String frontText,
    required String backText,
  });

  Future<void> deleteFlashcard(
    String flashcardId,
  );

  Future<void> toggleFavorite(
    String flashcardId,
  );
}