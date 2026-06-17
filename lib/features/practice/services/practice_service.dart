import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/practice_question.dart';
import '../../analytics/services/topic_mastery_service.dart';


class PracticeService {
  final _supabase =
      Supabase.instance.client;

  /// Generate practice questions
  /// from topic_quiz_questions
  Future<int> generatePracticeQuiz(
    String topicId,
  ) async {
    // Remove previous generated questions
    await _supabase
        .from('practice_questions')
        .delete()
        .eq(
          'topic_id',
          topicId,
        );

    final questions =
        await _supabase
            .from(
              'topic_quiz_questions',
            )
            .select()
            .eq(
              'topic_id',
              topicId,
            );

    if (questions.isEmpty) {
      return 0;
    }

    questions.shuffle();

    final selected =
        questions.take(10).toList();

    final inserts =
        selected.map((q) {
      return {
        'topic_id': topicId,
        'question': q['question'],
        'option_a': q['option_a'],
        'option_b': q['option_b'],
        'option_c': q['option_c'],
        'option_d': q['option_d'],
        'correct_answer':
            q['correct_answer'],
      };
    }).toList();

    await _supabase
        .from('practice_questions')
        .insert(inserts);

    return inserts.length;
  }

  /// Load generated practice questions
  Future<List<PracticeQuestion>>
      getPracticeQuestions(
    String topicId,
  ) async {
    final data =
        await _supabase
            .from(
              'practice_questions',
            )
            .select()
            .eq(
              'topic_id',
              topicId,
            )
            .order(
              'created_at',
              ascending: true,
            );

    return data
        .map<PracticeQuestion>(
          (item) =>
              PracticeQuestion.fromMap(
            item,
          ),
        )
        .toList();
  }

Future<void> saveAttempt({
  required String userId,
  required String topicId,
  required int score,
  required int totalQuestions,
}) async {
  print('SAVING PRACTICE ATTEMPT');

  await _supabase
      .from('practice_attempts')
      .insert({
    'user_id': userId,
    'topic_id': topicId,
    'score': score,
    'total_questions': totalQuestions,
  });

  print('ATTEMPT SAVED');

  final percentage =
      totalQuestions == 0
          ? 0.0
          : (score / totalQuestions) * 100;

  print('PERCENTAGE: $percentage');

  await TopicMasteryService()
      .updatePracticeMastery(
    studentId: userId,
    topicId: topicId,
    score: percentage,
  );

  print('PRACTICE MASTERY UPDATED');
}

  /// Get all attempts for a topic
  Future<List<Map<String, dynamic>>>
      getAttempts(
    String topicId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data =
        await _supabase
            .from(
              'practice_attempts',
            )
            .select()
            .eq(
              'user_id',
              user.id,
            )
            .eq(
              'topic_id',
              topicId,
            )
            .order(
              'created_at',
              ascending: false,
            );

    return List<Map<String, dynamic>>
        .from(data);
  }

  /// Get latest attempt
  Future<Map<String, dynamic>?>
      getLatestAttempt(
    String topicId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data =
        await _supabase
            .from(
              'practice_attempts',
            )
            .select()
            .eq(
              'user_id',
              user.id,
            )
            .eq(
              'topic_id',
              topicId,
            )
            .order(
              'created_at',
              ascending: false,
            )
            .limit(1);

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  Future<List<Map<String, dynamic>>>
    getPracticeAttempts(
  String topicId,
) async {
  final user =
      _supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  final data =
      await _supabase
          .from(
            'practice_attempts',
          )
          .select()
          .eq(
            'user_id',
            user.id,
          )
          .eq(
            'topic_id',
            topicId,
          )
          .order(
            'created_at',
            ascending: false,
          );

  return List<Map<String, dynamic>>
      .from(data);
}
}