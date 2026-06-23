import 'package:supabase_flutter/supabase_flutter.dart';

class TopicExamService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getExamByTopic(String topicId) async {
    final result = await _supabase
        .from('topic_exams')
        .select()
        .eq('topic_id', topicId)
        .maybeSingle();

    return result;
  }

  static Future<List<Map<String, dynamic>>> getQuestions(String examId) async {
    try {
      final result = await _supabase.rpc(
        'get_topic_exam_questions_safe',
        params: {'p_exam_id': examId},
      );

      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('get_topic_exam_questions_safe');

      if (!missingRpc) {
        rethrow;
      }
    }

    final result = await _supabase
        .from('topic_exam_questions')
        .select()
        .eq('exam_id', examId);

    return List<Map<String, dynamic>>.from(result);
  }

  static Future<Map<String, dynamic>?> submitAttemptSecure({
    required String examId,
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
        'submit_topic_exam_attempt_secure',
        params: {
          'p_exam_id': examId,
          'p_answers': sanitizedAnswers,
        },
      );
      return _asMap(result);
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_topic_exam_attempt_secure');

      if (missingRpc) {
        return null;
      }

      rethrow;
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
