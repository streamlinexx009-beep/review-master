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
    try {
      final data = await _supabase.rpc(
        'get_practice_questions_safe',
        params: {
          'p_topic_id': topicId,
          'p_limit': 10,
        },
      );

      return List<Map<String, dynamic>>.from(data)
          .map<PracticeQuestion>((item) => PracticeQuestion.fromMap(item))
          .toList();
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('get_practice_questions_safe');

      if (!missingRpc) {
        rethrow;
      }
    }

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

  Future<Map<String, dynamic>> saveAttempt({
    required String userId,
    required String topicId,
    required int score,
    required int totalQuestions,
    List<Map<String, dynamic>>? answers,
  }) async {
    if (answers != null && answers.isNotEmpty) {
      final secureResult = await _trySaveSecureAttempt(
        topicId: topicId,
        answers: answers,
      );

      if (secureResult != null) {
        final percentage = (secureResult['score'] as num?)?.toDouble() ??
            (totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100);

        await TopicMasteryService().updatePracticeMastery(
          studentId: userId,
          topicId: topicId,
          score: percentage,
        );
        return secureResult;
      }
    }

    final attempt = await _supabase
        .from('practice_attempts')
        .insert({
          'user_id': userId,
          'topic_id': topicId,
          'score': score,
          'total_questions': totalQuestions,
        })
        .select('id')
        .single();

    final percentage = totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100;

    await TopicMasteryService().updatePracticeMastery(
      studentId: userId,
      topicId: topicId,
      score: percentage,
    );

    return {
      'attempt_id': attempt['id'],
      'score': percentage,
      'correct_answers': score,
      'total_questions': totalQuestions,
    };
  }

  Future<Map<String, dynamic>?> _trySaveSecureAttempt({
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
      final result = await _supabase.rpc(
        'submit_practice_attempt_secure',
        params: {
          'p_topic_id': topicId,
          'p_answers': sanitizedAnswers,
        },
      );
      return _asMap(result);
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_practice_attempt_secure');

      if (missingRpc) {
        return null;
      }

      rethrow;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
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

  Future<List<Map<String, dynamic>>> getPracticeAttempts(String topicId) {
    return getAttempts(topicId);
  }
}
