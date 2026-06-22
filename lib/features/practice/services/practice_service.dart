import 'package:supabase_flutter/supabase_flutter.dart';

import '../../analytics/services/topic_mastery_service.dart';
import '../models/practice_question.dart';

class PracticeService {
  final _supabase = Supabase.instance.client;

  Future<int> generatePracticeQuiz(String topicId) async {
    final questions = await _supabase
        .from('topic_quiz_questions')
        .select('id')
        .eq('topic_id', topicId);

    return questions.length > 10 ? 10 : questions.length;
  }

  Future<List<PracticeQuestion>> getPracticeQuestions(String topicId) async {
    final data = await _supabase
        .from('topic_quiz_questions')
        .select()
        .eq('topic_id', topicId);

    final questions = List<Map<String, dynamic>>.from(data)..shuffle();

    return questions
        .take(10)
        .map<PracticeQuestion>((item) => PracticeQuestion.fromMap(item))
        .toList();
  }

  Future<void> saveAttempt({
    required String userId,
    required String topicId,
    required int score,
    required int totalQuestions,
    List<Map<String, dynamic>>? answers,
  }) async {
    if (answers != null && answers.isNotEmpty) {
      final savedSecurely = await _trySaveSecureAttempt(
        topicId: topicId,
        answers: answers,
      );

      if (savedSecurely) {
        final percentage = totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100;
        await TopicMasteryService().updatePracticeMastery(
          studentId: userId,
          topicId: topicId,
          score: percentage,
        );
        return;
      }
    }

    await _supabase.from('practice_attempts').insert({
      'user_id': userId,
      'topic_id': topicId,
      'score': score,
      'total_questions': totalQuestions,
    });

    final percentage = totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100;

    await TopicMasteryService().updatePracticeMastery(
      studentId: userId,
      topicId: topicId,
      score: percentage,
    );
  }

  Future<bool> _trySaveSecureAttempt({
    required String topicId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final sanitizedAnswers = answers.map((answer) {
      return {
        'question_id': answer['question_id'],
        'selected_answer': answer['selected_answer'],
      };
    }).toList();

    try {
      await _supabase.rpc(
        'submit_practice_attempt_secure',
        params: {
          'p_topic_id': topicId,
          'p_answers': sanitizedAnswers,
        },
      );
      return true;
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_practice_attempt_secure');

      if (missingRpc) {
        return false;
      }

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAttempts(String topicId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await _supabase
        .from('practice_attempts')
        .select()
        .eq('user_id', user.id)
        .eq('topic_id', topicId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getLatestAttempt(String topicId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('practice_attempts')
        .select()
        .eq('user_id', user.id)
        .eq('topic_id', topicId)
        .order('created_at', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  Future<List<Map<String, dynamic>>> getPracticeAttempts(String topicId) async {
    return getAttempts(topicId);
  }
}
