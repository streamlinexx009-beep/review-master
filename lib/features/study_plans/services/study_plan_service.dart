import 'package:supabase_flutter/supabase_flutter.dart';

import '../../study_planner/models/study_plan_model.dart';
import '../../study_planner/models/study_task_model.dart';

class StudyPlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User _requireUser() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return user;
  }

  Future<void> createStudyPlan({
    required String title,
    required String description,
  }) async {
    final user = _requireUser();

    await _supabase.from('study_plans').insert({
      'student_id': user.id,
      'title': title.trim(),
      'description': description.trim(),
    });
  }

  Future<List<StudyPlanModel>> getStudyPlans() async {
    final user = _requireUser();

    final response = await _supabase
        .from('study_plans')
        .select()
        .eq('student_id', user.id)
        .order('created_at', ascending: false);

    return response.map<StudyPlanModel>((plan) => StudyPlanModel.fromMap(plan)).toList();
  }

  Future<StudyPlanModel?> getStudyPlan(String studyPlanId) async {
    final response = await _supabase
        .from('study_plans')
        .select()
        .eq('id', studyPlanId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return StudyPlanModel.fromMap(response);
  }

  Future<void> deleteStudyPlan(String studyPlanId) async {
    _requireUser();

    await _supabase.from('study_plans').delete().eq('id', studyPlanId);
  }

  Future<void> createTask({
    required String studyPlanId,
    required String title,
    String description = '',
    DateTime? dueDate,
  }) async {
    _requireUser();

    await _supabase.from('study_tasks').insert({
      'study_plan_id': studyPlanId,
      'title': title.trim(),
      'description': description.trim(),
      'due_date': dueDate?.toIso8601String(),
    });
  }

  Future<List<StudyTaskModel>> getTasks(String studyPlanId) async {
    final response = await _supabase
        .from('study_tasks')
        .select()
        .eq('study_plan_id', studyPlanId)
        .order('due_date', nullsFirst: false)
        .order('created_at', ascending: true);

    return response.map<StudyTaskModel>((task) => StudyTaskModel.fromMap(task)).toList();
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required bool isCompleted,
  }) async {
    _requireUser();

    await _supabase
        .from('study_tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    _requireUser();

    await _supabase.from('study_tasks').delete().eq('id', taskId);
  }

  Future<StudyPlanModel?> getStudyPlanWithTasks(String studyPlanId) async {
    return getStudyPlan(studyPlanId);
  }

  Future<void> createWeakTopicPlan({
    required String topicName,
  }) async {
    final user = _requireUser();
    final planTitle = '${topicName.trim()} Improvement Plan';

    final existing = await _supabase
        .from('study_plans')
        .select('id')
        .eq('student_id', user.id)
        .eq('title', planTitle)
        .limit(1);

    if (existing.isNotEmpty) {
      throw Exception('Study plan already exists.');
    }

    final planResponse = await _supabase
        .from('study_plans')
        .insert({
          'student_id': user.id,
          'title': planTitle,
          'description': 'Auto-generated study plan based on analytics.',
          'status': 'pending',
        })
        .select('id')
        .single();

    final planId = planResponse['id'];

    await _supabase.from('study_tasks').insert([
      {
        'study_plan_id': planId,
        'title': 'Review Summary',
        'description': 'Read the topic summary.',
      },
      {
        'study_plan_id': planId,
        'title': 'Review Flashcards',
        'description': 'Review all flashcards.',
      },
      {
        'study_plan_id': planId,
        'title': 'Complete Practice Quiz',
        'description': 'Take a practice quiz.',
      },
      {
        'study_plan_id': planId,
        'title': 'Retake Topic Quiz',
        'description': 'Improve quiz score.',
      },
      {
        'study_plan_id': planId,
        'title': 'Take Topic Exam',
        'description': 'Measure mastery.',
      },
    ]);
  }
}
