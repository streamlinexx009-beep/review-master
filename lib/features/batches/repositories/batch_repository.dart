import '../models/batch_model.dart';

abstract class BatchRepository {
  Future<List<BatchModel>> getBatches();

  Future<BatchModel> getBatchById(
    String batchId,
  );

  Future<List<Map<String, dynamic>>>
      getStudents();

 Future<int> getStudentCount(
  String batchId,
);

  Future<void> createBatch({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> addStudentToBatch({
  required String batchId,
  required String studentId,
});

Future<List<String>>
    getEnrolledStudentIds(
  String batchId,
);

Future<void> removeStudentFromBatch({
  required String batchId,
  required String studentId,
});

Future<List<Map<String, dynamic>>>
    getBatchStudents(
  String batchId,
);

Future<List<Map<String, dynamic>>>
    getBatchSubjects(
  String batchId,
);

Future<void>
    assignSubjectToBatch({
  required String batchId,
  required String subjectId,
});

Future<void> removeSubjectFromBatch({
  required String batchId,
  required String subjectId,
});

Future<List<String>>
    getAssignedSubjectIds(
  String batchId,
);
}
