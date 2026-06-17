import '../models/subject_model.dart';

abstract class SubjectRepository {
  Future<List<SubjectModel>>
      getSubjects();

  Future<SubjectModel?>
      getSubjectById(
    String id,
  );

  Future<void> createSubject({
    required String name,
    String? description,
  });

  Future<void> updateSubject(
    SubjectModel subject,
  );

  Future<void> deleteSubject(
    String subjectId,
  );
}