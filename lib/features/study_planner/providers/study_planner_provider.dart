import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/study_planner_repository.dart';
import '../data/study_planner_repository_impl.dart';
import '../models/study_plan_model.dart';

final studyPlannerRepositoryProvider =
    Provider<StudyPlannerRepository>(
  (ref) {
    return StudyPlannerRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final studyPlansProvider =
    FutureProvider<List<StudyPlanModel>>(
  (ref) async {
    final repository = ref.read(
      studyPlannerRepositoryProvider,
    );

    return repository.getStudyPlans();
  },
);