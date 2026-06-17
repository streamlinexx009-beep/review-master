class StudyStreakModel {

  final int currentStreak;

  final int longestStreak;

  const StudyStreakModel({
    required this.currentStreak,
    required this.longestStreak,
  });

  factory StudyStreakModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return StudyStreakModel(
      currentStreak:
          map['current_streak'],
      longestStreak:
          map['longest_streak'],
    );
  }
}