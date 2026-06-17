class StudentPointsModel {

  final int points;

  final int level;

  const StudentPointsModel({
    required this.points,
    required this.level,
  });

  factory StudentPointsModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return StudentPointsModel(
      points: map['points'],
      level: map['level'],
    );
  }
}