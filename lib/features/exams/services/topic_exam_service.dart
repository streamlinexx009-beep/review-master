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
    final result = await _supabase
        .from('topic_exam_questions')
        .select()
        .eq('exam_id', examId);

    return List<Map<String, dynamic>>.from(result);
  }

  static Future<bool> submitAttemptSecure({
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
      await _supabase.rpc(
        'submit_topic_exam_attempt_secure',
        params: {
          'p_exam_id': examId,
          'p_answers': sanitizedAnswers,
        },
      );
      return true;
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_topic_exam_attempt_secure');

      if (missingRpc) {
        return false;
      }

      rethrow;
    }
  }
}
