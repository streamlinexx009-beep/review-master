import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/batch_model.dart';
import '../repositories/batch_repository.dart';
import '../repositories/batch_repository_impl.dart';

final batchRepositoryProvider =
    Provider<BatchRepository>(
  (ref) {
    return BatchRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final batchesProvider =
    FutureProvider<
      List<BatchModel>
    >(
  (ref) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getBatches();
  },
);

final batchProvider =
    FutureProvider.family<
      BatchModel,
      String
    >(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getBatchById(
          batchId,
        );
  },
);

final studentsProvider =
    FutureProvider<
      List<Map<String, dynamic>>
    >(
  (ref) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getStudents();
  },
);


final studentCountProvider =
    FutureProvider.family<
      int,
      String
    >(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getStudentCount(
          batchId,
        );
  },
);
final enrolledStudentIdsProvider =
    FutureProvider.family<
      List<String>,
      String
    >(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getEnrolledStudentIds(
          batchId,
        );
  },
);

final batchStudentsProvider =
    FutureProvider.family<
        List<Map<String, dynamic>>,
        String>(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getBatchStudents(
          batchId,
        );
  },
);

final batchStudentSearchProvider =
    StateProvider<String>(
  (ref) => '',
);

final batchSubjectsProvider =
    FutureProvider.family<
        List<Map<String, dynamic>>,
        String>(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getBatchSubjects(
          batchId,
        );
  },
);

final assignedSubjectIdsProvider =
    FutureProvider.family<
        List<String>,
        String>(
  (
    ref,
    batchId,
  ) {
    return ref
        .read(
          batchRepositoryProvider,
        )
        .getAssignedSubjectIds(
          batchId,
        );
  },
);