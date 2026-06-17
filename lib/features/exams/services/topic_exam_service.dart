import 'package:supabase_flutter/supabase_flutter.dart';

class TopicExamService {
  static final _supabase =
      Supabase.instance.client;

  static Future<Map<String, dynamic>?>
      getExamByTopic(
    String topicId,
  ) async {
    final result =
        await _supabase
            .from('topic_exams')
            .select()
            .eq('topic_id', topicId)
            .maybeSingle();

    return result;
  }

  static Future<List<Map<String, dynamic>>>
      getQuestions(
    String examId,
  ) async {
    final result =
        await _supabase
            .from(
              'topic_exam_questions',
            )
            .select()
            .eq('exam_id', examId);

    return List<Map<String, dynamic>>.from(
      result,
    );
  }
}