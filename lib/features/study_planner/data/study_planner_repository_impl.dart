import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/study_plan_model.dart';
import '../models/study_task_model.dart';
import 'study_planner_repository.dart';

class StudyPlannerRepositoryImpl implements StudyPlannerRepository {
  final SupabaseClient client;

  StudyPlannerRepositoryImpl(this.client);

  User _requireUser() {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return user;
  }

  @override
  Future<List<StudyPlanModel>> getStudyPlans() async {
    final user = _requireUser();

    final data = await client
        .from('study_plans')
        .select()
        .eq('student_id', user.id)
        .order('created_at', ascending: false);

    return data.map<StudyPlanModel>((e) => StudyPlanModel.fromMap(e)).toList();
  }

  @override
  Future<List<StudyTaskModel>> getTasks(String planId) async {
    final data = await client
        .from('study_tasks')
        .select()
        .eq('study_plan_id', planId)
        .order('due_date', nullsFirst: false)
        .order('created_at');

    return data.map<StudyTaskModel>((e) => StudyTaskModel.fromMap(e)).toList();
  }

  @override
  Future<void> createStudyPlan({
    required String title,
    required String description,
    DateTime? targetDate,
  }) async {
    final user = _requireUser();

    await client.from('study_plans').insert({
      'student_id': user.id,
      'title': title.trim(),
      'description': description.trim(),
      'target_date': targetDate?.toIso8601String(),
    });
  }

  @override
  Future<void> createTask({
    required String planId,
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    _requireUser();

    await client.from('study_tasks').insert({
      'study_plan_id': planId,
      'title': title.trim(),
      'description': description.trim(),
      'due_date': dueDate?.toIso8601String(),
    });
  }

  @override
  Future<void> toggleTask(String taskId, bool completed) async {
    _requireUser();

    await client
        .from('study_tasks')
        .update({'is_completed': completed})
        .eq('id', taskId);
  }

  @override
  Future<void> generateWeakTopicPlan(String topicName) async {
    final user = _requireUser();
    final planTitle = '${topicName.trim()} Improvement Plan';

    final existing = await client
        .from('study_plans')
        .select('id')
        .eq('student_id', user.id)
        .eq('title', planTitle)
        .limit(1);

    if (existing.isNotEmpty) {
      throw Exception('Study plan already exists.');
    }

    final plan = await client
        .from('study_plans')
        .insert({
          'student_id': user.id,
          'title': planTitle,
          'description': 'Auto-generated plan based on analytics.',
          'status': 'pending',
        })
        .select('id')
        .single();

    final planId = plan['id'];

    await client.from('study_tasks').insert([
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
