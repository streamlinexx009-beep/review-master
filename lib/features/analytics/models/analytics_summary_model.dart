class AnalyticsSummaryModel {

  final double overallAverage;

  final double bestScore;

  final double passRate;

  final int totalQuizzes;

  final int totalExams;

  final String performanceCategory;

  const AnalyticsSummaryModel({
    required this.overallAverage,
    required this.bestScore,
    required this.passRate,
    required this.totalQuizzes,
    required this.totalExams,
    required this.performanceCategory,
  });

  factory AnalyticsSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AnalyticsSummaryModel(
      overallAverage:
          (map['overall_average']
                  as num)
              .toDouble(),

      bestScore:
          (map['best_score']
                  as num)
              .toDouble(),

      passRate:
          (map['pass_rate']
                  as num)
              .toDouble(),

      totalQuizzes:
          map['total_quizzes'],

      totalExams:
          map['total_exams'],

      performanceCategory:
          map['performance_category'],
    );
  }
}