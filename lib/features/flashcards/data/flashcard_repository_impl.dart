import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/flashcard_model.dart';
import 'flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final SupabaseClient client;

  FlashcardRepositoryImpl(this.client);

  @override
  Future<List<FlashcardModel>> getFlashcards({
    String? topicId,
  }) async {
    final query = client.from('flashcards').select();

    final data = topicId == null
        ? await query.order('created_at', ascending: false)
        : await query.eq('topic_id', topicId).order('created_at', ascending: false);

    return data.map<FlashcardModel>((e) => FlashcardModel.fromMap(e)).toList();
  }

  @override
  Future<void> createFlashcard({
    required String subjectId,
    String? topicId,
    required String frontText,
    required String backText,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await client.from('flashcards').insert({
      'subject_id': subjectId,
      'topic_id': topicId,
      'front_text': frontText.trim(),
      'back_text': backText.trim(),
      'created_by': user.id,
    });
  }

  @override
  Future<void> deleteFlashcard(String flashcardId) async {
    await client.from('flashcards').delete().eq('id', flashcardId);
  }

  @override
  Future<void> toggleFavorite(String flashcardId) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final existing = await client
        .from('flashcard_favorites')
        .select('id')
        .eq('student_id', user.id)
        .eq('flashcard_id', flashcardId)
        .maybeSingle();

    if (existing != null) {
      await client
          .from('flashcard_favorites')
          .delete()
          .eq('student_id', user.id)
          .eq('flashcard_id', flashcardId);
      return;
    }

    await client.from('flashcard_favorites').insert({
      'student_id': user.id,
      'flashcard_id': flashcardId,
    });
  }
}
