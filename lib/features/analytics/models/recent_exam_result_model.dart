class RecentExamResultModel {
  final String examTitle;
  final double score;
  final bool passed;

  const RecentExamResultModel({
    required this.examTitle,
    required this.score,
    required this.passed,
  });
}