import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analytics_summary_model.dart';
import '../models/recent_exam_result_model.dart';
import '../models/performance_history_model.dart';
import 'analytics_repository.dart';
import '../models/topic_performance_model.dart';
import '../models/study_insights_model.dart';

class AnalyticsRepositoryImpl
    implements AnalyticsRepository {
  final SupabaseClient client;

  AnalyticsRepositoryImpl(
    this.client,
  );

  @override
  Future<AnalyticsSummaryModel>
      getSummary() async {
    final user =
        client.auth.currentUser!;

    final quizAttempts =
        await client
            .from('quiz_attempts')
            .select()
            .eq(
              'student_id',
              user.id,
            );

    double total = 0;

    double bestScore = 0;

    int passedCount = 0;

    for (final item
        in quizAttempts) {
      final score =
          (item['percentage']
                      as num?)
                  ?.toDouble() ??
              0;

      total += score;

      if (score > bestScore) {
        bestScore = score;
      }

      if (item['passed'] == true) {
        passedCount++;
      }
    }

    final double average =
        quizAttempts.isEmpty
            ? 0.0
            : total /
                quizAttempts.length;

    final double passRate =
        quizAttempts.isEmpty
            ? 0.0
            : (passedCount /
                    quizAttempts.length) *
                100;

    String category =
        'Needs Improvement';

    if (average >= 90) {
      category = 'Excellent';
    } else if (average >= 80) {
      category = 'Good';
    } else if (average >= 70) {
      category = 'Average';
    }

    return AnalyticsSummaryModel(
      overallAverage:
          average,

      bestScore:
          bestScore,

      passRate:
          passRate,

      totalQuizzes:
          quizAttempts.length,

      totalExams:
          0,

      performanceCategory:
          category,
    );
  }

  @override
  Future<List<RecentExamResultModel>>
      getRecentResults() async {
    final user =
        client.auth.currentUser!;

    final response =
        await client
            .from('quiz_attempts')
            .select('''
              percentage,
              passed,
              topics (
                name
              )
            ''')
            .eq(
              'student_id',
              user.id,
            )
            .order(
              'created_at',
              ascending: false,
            )
            .limit(5);

    return response.map(
      (item) {
        return RecentExamResultModel(
          examTitle:
              item['topics']
                      ?['name'] ??
                  'Quiz',

          score:
              (item['percentage']
                          as num?)
                      ?.toDouble() ??
                  0,

          passed:
              item['passed'] ??
                  false,
        );
      },
    ).toList();
  }

  @override
  Future<List<PerformanceHistoryModel>>
      getPerformanceHistory() async {
    final user =
        client.auth.currentUser!;

    final response =
        await client
            .from('quiz_attempts')
            .select('''
              percentage,
              topics (
                name
              )
            ''')
            .eq(
              'student_id',
              user.id,
            )
            .order(
              'created_at',
              ascending: true,
            );

    return response.map(
      (item) {
        return PerformanceHistoryModel(
          examTitle:
              item['topics']
                      ?['name'] ??
                  'Quiz',

          score:
              (item['percentage']
                          as num?)
                      ?.toDouble() ??
                  0,
        );
      },
    ).toList();
  }

  @override
Future<List<TopicPerformanceModel>>
    getTopicPerformance() async {
  final user =
      client.auth.currentUser!;

  final response =
      await client
          .from('quiz_attempts')
          .select('''
            percentage,
            topic_id,
            topics (
              name
            )
          ''')
          .eq(
            'student_id',
            user.id,
          );

  final Map<String, List<double>>
      scores = {};

  for (final item in response) {
    final topic =
        item['topics']?['name'] ??
            'Unknown Topic';

    final score =
        (item['percentage']
                    as num?)
                ?.toDouble() ??
            0;

    scores.putIfAbsent(
      topic,
      () => [],
    );

    scores[topic]!.add(score);
  }

  return scores.entries.map(
    (entry) {
      final average =
          entry.value.reduce(
                (a, b) => a + b,
              ) /
              entry.value.length;

      return TopicPerformanceModel(
        topicName:
            entry.key,
        averageScore:
            average,
        attempts:
            entry.value.length,
      );
    },
  ).toList()
    ..sort(
      (a, b) => b.averageScore.compareTo(
        a.averageScore,
      ),
    );
}

@override
Future<StudyInsightsModel>
    getStudyInsights() async {
  final topics =
      await getTopicPerformance();

  if (topics.isEmpty) {
    return const StudyInsightsModel(
      strongestTopic: 'N/A',
      strongestScore: 0,
      weakestTopic: 'N/A',
      weakestScore: 0,
      studyStreak: 0,
      recommendation:
          'Take your first quiz.',
    );
  }

  final strongest =
      topics.first;

  final weakest =
      topics.last;

  final user =
    client.auth.currentUser!;

final attempts =
    await client
        .from('quiz_attempts')
        .select('created_at')
        .eq(
          'student_id',
          user.id,
        )
        .order(
          'created_at',
          ascending: false,
        );

int streak = 0;

if (attempts.isNotEmpty) {
  final dates =
      attempts
          .map(
            (item) => DateTime.parse(
              item['created_at'],
            ),
          )
          .map(
            (d) => DateTime(
              d.year,
              d.month,
              d.day,
            ),
          )
          .toSet()
          .toList()
        ..sort(
          (a, b) =>
              b.compareTo(a),
        );

  var expected =
      DateTime.now();

  expected = DateTime(
    expected.year,
    expected.month,
    expected.day,
  );

  for (final date in dates) {
    if (date == expected) {
      streak++;

      expected =
          expected.subtract(
        const Duration(
          days: 1,
        ),
      );
    } else {
      break;
    }
  }
}

  return StudyInsightsModel(
    strongestTopic:
        strongest.topicName,

    strongestScore:
        strongest.averageScore,

    weakestTopic:
        weakest.topicName,

    weakestScore:
        weakest.averageScore,

    studyStreak:
        streak,

    recommendation:
        'Review ${weakest.topicName} flashcards and retake the quiz.',
  );
}
}