import '../models/analytics_summary_model.dart';
import '../models/performance_history_model.dart';
import '../models/recent_exam_result_model.dart';
import '../models/topic_performance_model.dart';
import '../models/study_insights_model.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummaryModel>
      getSummary();

  Future<List<RecentExamResultModel>>
      getRecentResults();

  Future<List<PerformanceHistoryModel>>
      getPerformanceHistory();

  Future<List<TopicPerformanceModel>>
      getTopicPerformance();

  Future<StudyInsightsModel>
      getStudyInsights();
}