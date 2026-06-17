import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/study_planner_repository.dart';
import 'study_planner_provider.dart';

final studyPlannerControllerProvider =
    Provider(
  (ref) {
    return StudyPlannerController(
      ref.read(
        studyPlannerRepositoryProvider,
      ),
    );
  },
);

class StudyPlannerController {
  final StudyPlannerRepository
      repository;

  StudyPlannerController(
    this.repository,
  );

  Future<void>
      generateWeakTopicPlan(
    String topicName,
  ) async {
    await repository
        .generateWeakTopicPlan(
      topicName,
    );
  }
}