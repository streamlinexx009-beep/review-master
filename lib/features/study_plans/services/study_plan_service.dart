import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/study_plan_model.dart';
import '../models/study_task_model.dart';

class StudyPlanService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  /// CREATE STUDY PLAN
  Future<void> createStudyPlan({
    required String title,
    required String description,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    await _supabase
        .from('study_plans')
        .insert({
      'user_id': user.id,
      'title': title,
      'description': description,
    });
  }

  /// GET ALL STUDY PLANS
  Future<List<StudyPlanModel>>
      getStudyPlans() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response =
        await _supabase
            .from('study_plans')
            .select()
            .eq(
              'user_id',
              user.id,
            )
            .order(
              'created_at',
              ascending: false,
            );

    return response
        .map<StudyPlanModel>(
          (plan) =>
              StudyPlanModel.fromMap(
            plan,
          ),
        )
        .toList();
  }

  /// GET SINGLE STUDY PLAN
  Future<StudyPlanModel?>
      getStudyPlan(
    String studyPlanId,
  ) async {
    final response =
        await _supabase
            .from('study_plans')
            .select()
            .eq(
              'id',
              studyPlanId,
            )
            .maybeSingle();

    if (response == null) {
      return null;
    }

    return StudyPlanModel.fromMap(
      response,
    );
  }

  /// DELETE STUDY PLAN
  Future<void> deleteStudyPlan(
    String studyPlanId,
  ) async {
    await _supabase
        .from('study_plans')
        .delete()
        .eq(
          'id',
          studyPlanId,
        );
  }

  /// CREATE TASK
  Future<void> createTask({
    required String studyPlanId,
    required String title,
    String description = '',
    DateTime? dueDate,
  }) async {
    await _supabase
        .from('study_tasks')
        .insert({
      'study_plan_id':
          studyPlanId,
      'title': title,
      'description':
          description,
      'due_date':
          dueDate
              ?.toIso8601String(),
    });
  }

  /// GET TASKS FOR PLAN
  Future<List<StudyTaskModel>>
      getTasks(
    String studyPlanId,
  ) async {
    final response =
        await _supabase
            .from('study_tasks')
            .select()
            .eq(
              'study_plan_id',
              studyPlanId,
            )
            .order(
              'created_at',
              ascending: true,
            );

    return response
        .map<StudyTaskModel>(
          (task) =>
              StudyTaskModel.fromMap(
            task,
          ),
        )
        .toList();
  }

  /// UPDATE TASK STATUS
  Future<void> updateTaskStatus({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _supabase
        .from('study_tasks')
        .update({
      'is_completed':
          isCompleted,
    })
        .eq(
      'id',
      taskId,
    );
  }

  /// DELETE TASK
  Future<void> deleteTask(
    String taskId,
  ) async {
    await _supabase
        .from('study_tasks')
        .delete()
        .eq(
          'id',
          taskId,
        );
  }

  /// GET PLAN WITH TASKS
  Future<StudyPlanModel?>
      getStudyPlanWithTasks(
    String studyPlanId,
  ) async {
    final plan =
        await getStudyPlan(
      studyPlanId,
    );

    if (plan == null) {
      return null;
    }

    final tasks =
        await getTasks(
      studyPlanId,
    );

    return plan.copyWith(
      tasks: tasks,
    );
  }

  /// AUTO GENERATE PLAN FROM WEAK TOPIC
  Future<void>
      createWeakTopicPlan({
    required String topicName,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    final planResponse =
        await _supabase
            .from('study_plans')
            .insert({
      'user_id': user.id,
      'title':
          '$topicName Improvement Plan',
      'description':
          'Auto-generated study plan based on analytics.',
    })
            .select()
            .single();

    final planId =
        planResponse['id'];

    await _supabase
        .from('study_tasks')
        .insert([
      {
        'study_plan_id':
            planId,
        'title':
            'Review Summary',
      },
      {
        'study_plan_id':
            planId,
        'title':
            'Review Flashcards',
      },
      {
        'study_plan_id':
            planId,
        'title':
            'Complete Practice Quiz',
      },
      {
        'study_plan_id':
            planId,
        'title':
            'Retake Topic Quiz',
      },
      {
        'study_plan_id':
            planId,
        'title':
            'Take Topic Exam',
      },
    ]);
  }
}