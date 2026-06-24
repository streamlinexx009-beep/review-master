import '../../study_planner/models/study_task_model.dart';

class StudyPlanModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final String status;
  final List<StudyTaskModel> tasks;

  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.tasks,
  });

  factory StudyPlanModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawTasks = map['tasks'];

    return StudyPlanModel(
      id: map['id']?.toString() ?? '',
      userId:
          map['user_id']?.toString() ??
          map['student_id']?.toString() ??
          '',
      title: map['title']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(
                  map['created_at']
                      .toString(),
                )
              : DateTime.now(),
      status:
          map['status']?.toString() ??
          'pending',
      tasks:
          rawTasks is List
              ? rawTasks
                  .whereType<Map>()
                  .map(
                    (task) => StudyTaskModel.fromMap(
                      Map<String, dynamic>.from(task),
                    ),
                  )
                  .toList()
              : <StudyTaskModel>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'created_at':
          createdAt.toIso8601String(),
      'status': status,
    };
  }

  StudyPlanModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
    List<StudyTaskModel>? tasks,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      userId:
          userId ?? this.userId,
      title: title ?? this.title,
      description:
          description ??
          this.description,
      createdAt:
          createdAt ??
          this.createdAt,
      status:
          status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }

  int get completedTasks =>
      tasks
          .where(
            (task) =>
                task.isCompleted,
          )
          .length;

  int get totalTasks =>
      tasks.length;

  double get progress {
    if (tasks.isEmpty) {
      return 0;
    }

    return (completedTasks /
            totalTasks) *
        100;
  }

  /// Computed status based on tasks
  /// Used if database status is not yet updated
  String get computedStatus {
    if (tasks.isEmpty) {
      return 'pending';
    }

    if (completedTasks == 0) {
      return 'pending';
    }

    if (completedTasks ==
        totalTasks) {
      return 'completed';
    }

    return 'in_progress';
  }

  bool get isCompleted =>
      completedTasks ==
          totalTasks &&
      totalTasks > 0;
}
