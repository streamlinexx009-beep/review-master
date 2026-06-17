import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/flashcard_model.dart';
import 'flashcard_repository.dart';

class FlashcardRepositoryImpl
    implements FlashcardRepository {

  final SupabaseClient client;

  FlashcardRepositoryImpl(
    this.client,
  );

  @override
  Future<List<FlashcardModel>>
      getFlashcards({
    String? topicId,
  }) async {

    final data =
        topicId == null
            ? await client
                .from('flashcards')
                .select()
            : await client
                .from('flashcards')
                .select()
                .eq(
                  'topic_id',
                  topicId,
                );

    return data
        .map<FlashcardModel>(
          (e) =>
              FlashcardModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<void> createFlashcard({
    required String subjectId,
    String? topicId,
    required String frontText,
    required String backText,
  }) async {

    final user =
        client.auth.currentUser!;

    await client
        .from('flashcards')
        .insert({
      'subject_id': subjectId,
      'topic_id': topicId,
      'front_text': frontText,
      'back_text': backText,
      'created_by': user.id,
    });
  }

  @override
  Future<void> deleteFlashcard(
    String flashcardId,
  ) async {

    await client
        .from('flashcards')
        .delete()
        .eq(
          'id',
          flashcardId,
        );
  }

  @override
  Future<void> toggleFavorite(
    String flashcardId,
  ) async {
    // TODO
  }
}