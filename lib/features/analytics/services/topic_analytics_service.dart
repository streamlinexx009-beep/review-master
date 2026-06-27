import 'package:supabase_flutter/supabase_flutter.dart';

class TopicAnalyticsService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>>
      getTopicPerformance() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final attempts =
        await _supabase
            .from('practice_attempts')
            .select('''
              score,
              total_questions,
              topic_id,
              topics(name)
            ''')
            .eq('user_id', user.id);

    final Map<String, List<double>>
        topicScores = {};

    for (final item in attempts) {
      final score =
          (item['score'] as num)
              .toDouble();

      final total =
          item['total_questions']
              as int;

      final percentage =
          total == 0 ? 0.0 : (score / total) * 100;

      final topic =
          item['topics']['name']
              as String;

      topicScores.putIfAbsent(
        topic,
        () => [],
      );

      topicScores[topic]!
          .add(percentage);
    }

    final results =
        topicScores.entries.map((e) {
      final avg =
          e.value.reduce(
                (a, b) => a + b,
              ) /
              e.value.length;

      return {
        'topic': e.key,
        'average': avg,
      };
    }).toList();

    results.sort(
      (a, b) => (a['average'] as double)
          .compareTo(
        b['average'] as double,
      ),
    );

    return results;
  }
}
