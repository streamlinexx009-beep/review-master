class StudyInsightsModel {
  final String strongestTopic;
  final double strongestScore;

  final String weakestTopic;
  final double weakestScore;

  final int studyStreak;

  final String recommendation;

  const StudyInsightsModel({
    required this.strongestTopic,
    required this.strongestScore,
    required this.weakestTopic,
    required this.weakestScore,
    required this.studyStreak,
    required this.recommendation,
  });
}