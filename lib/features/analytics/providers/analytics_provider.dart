import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/analytics_repository.dart';
import '../data/analytics_repository_impl.dart';

import '../models/analytics_summary_model.dart';
import '../models/recent_exam_result_model.dart';
import '../models/performance_history_model.dart';
import '../models/topic_performance_model.dart';
import '../models/study_insights_model.dart';
import '../models/topic_mastery_model.dart';

final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>(
  (ref) {
    return AnalyticsRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final analyticsSummaryProvider =
    FutureProvider<AnalyticsSummaryModel>(
  (ref) {
    return ref
        .read(
          analyticsRepositoryProvider,
        )
        .getSummary();
  },
);

final recentResultsProvider =
    FutureProvider<List<RecentExamResultModel>>(
  (ref) {
    return ref
        .read(
          analyticsRepositoryProvider,
        )
        .getRecentResults();
  },
);

final performanceHistoryProvider =
    FutureProvider<List<PerformanceHistoryModel>>(
  (ref) {
    return ref
        .read(
          analyticsRepositoryProvider,
        )
        .getPerformanceHistory();
  },
);

final topicPerformanceProvider =
    FutureProvider<List<TopicPerformanceModel>>(
  (ref) {
    return ref
        .read(
          analyticsRepositoryProvider,
        )
        .getTopicPerformance();
  },
);

final studyInsightsProvider =
    FutureProvider<StudyInsightsModel>(
  (ref) {
    return ref
        .read(
          analyticsRepositoryProvider,
        )
        .getStudyInsights();
  },
);

final topicMasteryProvider =
    FutureProvider<List<TopicMasteryModel>>(
  (ref) async {
    final supabase =
        Supabase.instance.client;

    final user =
        supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    await supabase.rpc(
      'calculate_topic_mastery',
      params: {
        'p_student_id': user.id,
      },
    );

    final data =
    await supabase
        .from('topic_mastery')
        .select('''
          overall_mastery,
          flashcard_mastery,
          practice_mastery,
          quiz_mastery,
          exam_mastery,
          topics(
            name
          )
        ''')
        .eq(
          'student_id',
          user.id,
        )
        .order(
          'overall_mastery',
          ascending: false,
        );

    return data.map((row) {
  return TopicMasteryModel(
    topicName:
        row['topics']['name'],

    mastery:
        (row['overall_mastery'] as num)
            .toDouble(),

    flashcardMastery:
        (row['flashcard_mastery'] as num?)
                ?.toDouble() ??
            0,

    practiceMastery:
        (row['practice_mastery'] as num?)
                ?.toDouble() ??
            0,

    quizMastery:
        (row['quiz_mastery'] as num?)
                ?.toDouble() ??
            0,

    examMastery:
        (row['exam_mastery'] as num?)
                ?.toDouble() ??
            0,
  );
}).toList();
  },
);