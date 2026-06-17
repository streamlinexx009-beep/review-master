class AchievementModel {

  final String id;

  final String title;

  final String description;

  final String? icon;

  final int points;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    required this.points,
  });

  factory AchievementModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return AchievementModel(
      id: map['id'],
      title: map['title'],
      description:
          map['description'] ?? '',
      icon: map['icon'],
      points: map['points'],
    );
  }
}