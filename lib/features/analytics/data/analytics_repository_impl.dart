import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analytics_summary_model.dart';
import '../models/performance_history_model.dart';
import '../models/recent_exam_result_model.dart';
import '../models/study_insights_model.dart';
import '../models/topic_performance_model.dart';
import 'analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final SupabaseClient client;

  AnalyticsRepositoryImpl(this.client);

  User _requireUser() {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return user;
  }

  @override
  Future<AnalyticsSummaryModel> getSummary() async {
    final user = _requireUser();

    final quizAttempts = await client
        .from('quiz_attempts')
        .select('percentage, passed')
        .eq('student_id', user.id);

    final examAttempts = await client
        .from('exam_attempts')
        .select('score, passed')
        .eq('student_id', user.id);

    final scores = <double>[];
    var passedCount = 0;

    for (final item in quizAttempts) {
      scores.add((item['percentage'] as num?)?.toDouble() ?? 0);
      if (item['passed'] == true) passedCount++;
    }

    for (final item in examAttempts) {
      scores.add((item['score'] as num?)?.toDouble() ?? 0);
      if (item['passed'] == true) passedCount++;
    }

    final totalAttempts = scores.length;
    final total = scores.fold<double>(0, (sum, score) => sum + score);
    final average = totalAttempts == 0 ? 0.0 : total / totalAttempts;
    final bestScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);
    final passRate = totalAttempts == 0 ? 0.0 : (passedCount / totalAttempts) * 100;

    var category = 'Needs Improvement';
    if (average >= 90) {
      category = 'Excellent';
    } else if (average >= 80) {
      category = 'Good';
    } else if (average >= 70) {
      category = 'Average';
    }

    return AnalyticsSummaryModel(
      overallAverage: average,
      bestScore: bestScore,
      passRate: passRate,
      totalQuizzes: quizAttempts.length,
      totalExams: examAttempts.length,
      performanceCategory: category,
    );
  }

  @override
  Future<List<RecentExamResultModel>> getRecentResults() async {
    final user = _requireUser();

    final response = await client
        .from('quiz_attempts')
        .select('''
          percentage,
          passed,
          topics (
            name
          )
        ''')
        .eq('student_id', user.id)
        .order('created_at', ascending: false)
        .limit(5);

    return response.map((item) {
      return RecentExamResultModel(
        examTitle: item['topics']?['name'] ?? 'Quiz',
        score: (item['percentage'] as num?)?.toDouble() ?? 0,
        passed: item['passed'] ?? false,
      );
    }).toList();
  }

  @override
  Future<List<PerformanceHistoryModel>> getPerformanceHistory() async {
    final user = _requireUser();

    final response = await client
        .from('quiz_attempts')
        .select('''
          percentage,
          topics (
            name
          )
        ''')
        .eq('student_id', user.id)
        .order('created_at', ascending: true);

    return response.map((item) {
      return PerformanceHistoryModel(
        examTitle: item['topics']?['name'] ?? 'Quiz',
        score: (item['percentage'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  @override
  Future<List<TopicPerformanceModel>> getTopicPerformance() async {
    final user = _requireUser();

    final response = await client
        .from('quiz_attempts')
        .select('''
          percentage,
          topic_id,
          topics (
            name
          )
        ''')
        .eq('student_id', user.id);

    final scores = <String, List<double>>{};

    for (final item in response) {
      final topic = item['topics']?['name'] ?? 'Unknown Topic';
      final score = (item['percentage'] as num?)?.toDouble() ?? 0;

      scores.putIfAbsent(topic, () => []);
      scores[topic]!.add(score);
    }

    return scores.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;

      return TopicPerformanceModel(
        topicName: entry.key,
        averageScore: average,
        attempts: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
  }

  @override
  Future<StudyInsightsModel> getStudyInsights() async {
    final topics = await getTopicPerformance();

    if (topics.isEmpty) {
      return const StudyInsightsModel(
        strongestTopic: 'N/A',
        strongestScore: 0,
        weakestTopic: 'N/A',
        weakestScore: 0,
        studyStreak: 0,
        recommendation: 'Take your first quiz.',
      );
    }

    final strongest = topics.first;
    final weakest = topics.last;
    final user = _requireUser();

    final attempts = await client
        .from('quiz_attempts')
        .select('created_at')
        .eq('student_id', user.id)
        .order('created_at', ascending: false);

    var streak = 0;

    if (attempts.isNotEmpty) {
      final dates = attempts
          .map((item) => DateTime.parse(item['created_at']))
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      var expected = DateTime.now();
      expected = DateTime(expected.year, expected.month, expected.day);

      for (final date in dates) {
        if (date == expected) {
          streak++;
          expected = expected.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return StudyInsightsModel(
      strongestTopic: strongest.topicName,
      strongestScore: strongest.averageScore,
      weakestTopic: weakest.topicName,
      weakestScore: weakest.averageScore,
      studyStreak: streak,
      recommendation: 'Review ${weakest.topicName} flashcards and retake the quiz.',
    );
  }
}
