import '../models/study_plan_model.dart';
import '../models/study_task_model.dart';

abstract class StudyPlannerRepository {

  Future<List<StudyPlanModel>>
      getStudyPlans();

  Future<List<StudyTaskModel>>
      getTasks(
    String planId,
  );

  Future<void> createStudyPlan({
    required String title,
    required String description,
    DateTime? targetDate,
  });

  Future<void> createTask({
    required String planId,
    required String title,
    required String description,
    DateTime? dueDate,
  });

  Future<void> toggleTask(
    String taskId,
    bool completed,
  );

  Future<void> generateWeakTopicPlan(
  String topicName,
);
}