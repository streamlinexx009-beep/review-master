import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>> getDashboardData(
    String studentId,
  ) async {
    final masteryRows =
        await _supabase
            .from('topic_mastery')
            .select()
            .eq('student_id', studentId);

    if (masteryRows.isEmpty) {
      return {
        'overallMastery': 0.0,
        'quizAverage': 0.0,
        'examAverage': 0.0,
        'practiceAverage': 0.0,
        'topicCount': 0,
      };
    }

    double overall = 0;
    double quiz = 0;
    double exam = 0;
    double practice = 0;

    for (final row in masteryRows) {
      overall +=
          (row['overall_mastery'] as num?)
                  ?.toDouble() ??
              0;

      quiz +=
          (row['quiz_mastery'] as num?)
                  ?.toDouble() ??
              0;

      exam +=
          (row['exam_mastery'] as num?)
                  ?.toDouble() ??
              0;

      practice +=
          (row['practice_mastery'] as num?)
                  ?.toDouble() ??
              0;
    }

    final count = masteryRows.length;

    return {
      'overallMastery': overall / count,
      'quizAverage': quiz / count,
      'examAverage': exam / count,
      'practiceAverage': practice / count,
      'topicCount': count,
    };
  }
}