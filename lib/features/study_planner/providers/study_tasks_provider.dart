import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_task_model.dart';
import 'study_planner_provider.dart';

final studyTasksProvider = FutureProvider.family<
    List<StudyTaskModel>,
    String>(
  (ref, planId) async {
    final repository = ref.read(
      studyPlannerRepositoryProvider,
    );

    return repository.getTasks(
      planId,
    );
  },
);