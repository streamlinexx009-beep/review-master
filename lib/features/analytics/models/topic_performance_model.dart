class TopicPerformanceModel {
  final String topicName;
  final double averageScore;
  final int attempts;

  String get masteryLevel {
  if (averageScore >= 90) {
    return '🏅 Mastered';
  }

  if (averageScore >= 80) {
    return '📘 Proficient';
  }

  if (averageScore >= 60) {
    return '📖 Developing';
  }

  return '⚠ Beginner';
}

  const TopicPerformanceModel({
    required this.topicName,
    required this.averageScore,
    required this.attempts,
  });
}