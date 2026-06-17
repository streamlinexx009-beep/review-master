import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/quiz_repository.dart';
import '../data/quiz_repository_impl.dart';
import '../models/quiz_model.dart';

final quizRepositoryProvider =
    Provider<QuizRepository>(
  (ref) {
    return QuizRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final quizzesProvider =
    FutureProvider<
        List<QuizModel>>(
  (ref) {
    return ref
        .read(
          quizRepositoryProvider,
        )
        .getQuizzes();
  },
);