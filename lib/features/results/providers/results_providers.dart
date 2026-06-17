import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exams/providers/exam_provider.dart';
import '../../exams/models/exam_attempt_model.dart';
import '../../exams/models/exam_attempt_answer_model.dart';

final myResultsProvider =
    FutureProvider<List<ExamAttemptModel>>(
  (ref) {
    return ref
        .read(
          examRepositoryProvider,
        )
        .getMyAttempts();
  },
);

final attemptAnswersProvider =
    FutureProvider.family<
        List<ExamAttemptAnswerModel>,
        String>(
  (ref, attemptId) {
    return ref
        .read(
          examRepositoryProvider,
        )
        .getAttemptAnswers(
          attemptId,
        );
  },
);