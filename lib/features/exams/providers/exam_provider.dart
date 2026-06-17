import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/exam_repository.dart';
import '../data/exam_repository_impl.dart';

import '../models/exam_model.dart';
import '../models/exam_question_model.dart';

final examRepositoryProvider =
    Provider<ExamRepository>(
  (ref) {
    return ExamRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final examsProvider =
    FutureProvider<List<ExamModel>>(
  (ref) {
    return ref
        .read(
          examRepositoryProvider,
        )
        .getExams();
  },
);

final examProvider =
    FutureProvider.family<
        ExamModel?,
        String>(
  (ref, examId) async {
    final exams = await ref
        .read(
          examRepositoryProvider,
        )
        .getExams();

    try {
      return exams.firstWhere(
        (exam) =>
            exam.id == examId,
      );
    } catch (_) {
      return null;
    }
  },
);

final examQuestionsProvider =
    FutureProvider.family<
        List<ExamQuestionModel>,
        String>(
  (ref, examId) {
    return ref
        .read(
          examRepositoryProvider,
        )
        .getQuestions(
          examId,
        );
  },
);