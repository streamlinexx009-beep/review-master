class StudyPlanModel {

  final String id;

  final String studentId;

  final String title;

  final String description;

  final DateTime? targetDate;

  final String status;

  const StudyPlanModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    this.targetDate,
    required this.status,
  });

  factory StudyPlanModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return StudyPlanModel(
      id: map['id'],
      studentId: map['student_id'],
      title: map['title'],
      description:
          map['description'] ?? '',
      targetDate:
          map['target_date'] != null
              ? DateTime.parse(
                  map['target_date'],
                )
              : null,
      status: map['status'],
    );
  }
}