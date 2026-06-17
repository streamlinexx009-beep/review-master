class RecommendationModel {
  final String topicName;
  final double mastery;
  final String level;
  final List<String> actions;

  RecommendationModel({
    required this.topicName,
    required this.mastery,
    required this.level,
    required this.actions,
  });
}