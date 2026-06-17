class StudyTaskModel {

  final String id;

  final String studyPlanId;

  final String title;

  final String description;

  final DateTime? dueDate;

  final bool isCompleted;

  const StudyTaskModel({
    required this.id,
    required this.studyPlanId,
    required this.title,
    required this.description,
    this.dueDate,
    required this.isCompleted,
  });

  factory StudyTaskModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return StudyTaskModel(
      id: map['id'],
      studyPlanId:
          map['study_plan_id'],
      title: map['title'],
      description:
          map['description'] ?? '',
      dueDate:
          map['due_date'] != null
              ? DateTime.parse(
                  map['due_date'],
                )
              : null,
      isCompleted:
          map['is_completed'],
    );
  }
}