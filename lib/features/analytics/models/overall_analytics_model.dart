class OverallAnalyticsModel {
  final double overallAverage;

  final double quizAverage;

  final double examAverage;

  final List<String> strongTopics;

  final List<String> weakTopics;

  final String performanceCategory;

  const OverallAnalyticsModel({
    required this.overallAverage,
    required this.quizAverage,
    required this.examAverage,
    required this.strongTopics,
    required this.weakTopics,
    required this.performanceCategory,
  });
}