class LeaderboardModel {

  final String studentName;

  final int points;

  final int rank;

  const LeaderboardModel({
    required this.studentName,
    required this.points,
    required this.rank,
  });

  factory LeaderboardModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return LeaderboardModel(
      studentName:
          map['student_name'],
      points:
          map['points'],
      rank:
          map['rank'],
    );
  }
}