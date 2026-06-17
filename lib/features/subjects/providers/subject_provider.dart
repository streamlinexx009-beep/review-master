import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/subject_repository.dart';
import '../data/subject_repository_impl.dart';
import '../models/subject_model.dart';

final subjectRepositoryProvider =
    Provider<SubjectRepository>(
  (ref) {
    return SubjectRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final subjectsProvider =
    FutureProvider<List<SubjectModel>>(
  (ref) async {
    return ref
        .read(
          subjectRepositoryProvider,
        )
        .getSubjects();
  },
);

final subjectProvider =
    FutureProvider.family<
        SubjectModel?,
        String>(
  (
    ref,
    subjectId,
  ) async {
    return ref
        .read(
          subjectRepositoryProvider,
        )
        .getSubjectById(
          subjectId,
        );
  },
);