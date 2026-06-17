import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/batch_model.dart';
import 'batch_repository.dart';

class BatchRepositoryImpl
    implements BatchRepository {
  final SupabaseClient supabase;

  BatchRepositoryImpl(
    this.supabase,
  );

  @override
  Future<List<BatchModel>>
      getBatches() async {
    final response =
        await supabase
            .from('batches')
            .select()
            .order(
              'created_at',
              ascending: false,
            );

    return response
        .map<BatchModel>(
          (batch) =>
              BatchModel.fromMap(
                batch,
              ),
        )
        .toList();
  }

  @override
  Future<BatchModel> getBatchById(
    String batchId,
  ) async {
    final response =
        await supabase
            .from('batches')
            .select()
            .eq(
              'id',
              batchId,
            )
            .single();

    return BatchModel.fromMap(
      response,
    );
  }

  @override
  Future<List<Map<String, dynamic>>>
      getStudents() async {
    final response =
        await supabase
            .from('profiles')
            .select()
            .eq(
              'role',
              'student',
            )
            .order(
              'email',
            );

    return List<Map<String, dynamic>>
        .from(response);
  }


@override
Future<int> getStudentCount(
  String batchId,
) async {
  final response =
      await supabase
          .from('batch_students')
          .select()
          .eq(
            'batch_id',
            batchId,
          );

  return response.length;
}

@override
Future<List<String>>
    getEnrolledStudentIds(
  String batchId,
) async {
  final response =
      await supabase
          .from(
            'batch_students',
          )
          .select(
            'student_id',
          )
          .eq(
            'batch_id',
            batchId,
          );

  return response
      .map<String>(
        (
          row,
        ) =>
            row[
                'student_id']
            as String,
      )
      .toList();
}

  @override
  Future<void> createBatch({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await supabase
        .from('batches')
        .insert({
          'name': name,
          'description':
              description,
          'start_date':
              startDate
                  ?.toIso8601String(),
          'end_date':
              endDate
                  ?.toIso8601String(),
        });
  }

  @override
Future<void> addStudentToBatch({
  required String batchId,
  required String studentId,
}) async {
  await supabase
      .from('batch_students')
      .insert({
        'batch_id': batchId,
        'student_id': studentId,
      });
}

@override
Future<void> removeStudentFromBatch({
  required String batchId,
  required String studentId,
}) async {
  await supabase
      .from('batch_students')
      .delete()
      .eq('batch_id', batchId)
      .eq('student_id', studentId);
}

@override
Future<List<Map<String, dynamic>>>
    getBatchStudents(
  String batchId,
) async {
  final response =
      await supabase
          .from('batch_students')
          .select(
            '''
            student_id,
            profiles(
              id,
              full_name,
              email
            )
            ''',
          )
          .eq(
            'batch_id',
            batchId,
          );

  return List<Map<String, dynamic>>.from(
    response,
  );
}
@override
Future<List<Map<String, dynamic>>>
    getBatchSubjects(
  String batchId,
) async {
  final response =
      await supabase
          .from(
            'batch_subjects',
          )
          .select(
            '''
            subject_id,
            subjects(
              id,
              name,
              description
            )
            ''',
          )
          .eq(
            'batch_id',
            batchId,
          );

  return List<Map<String, dynamic>>.from(
    response,
  );
}

@override
Future<List<String>>
    getAssignedSubjectIds(
  String batchId,
) async {
  final response =
      await supabase
          .from(
            'batch_subjects',
          )
          .select(
            'subject_id',
          )
          .eq(
            'batch_id',
            batchId,
          );

  return response
      .map<String>(
        (row) =>
            row['subject_id']
                as String,
      )
      .toList();
}

@override
Future<void>
    assignSubjectToBatch({
  required String batchId,
  required String subjectId,
}) async {
  await supabase
      .from(
        'batch_subjects',
      )
      .insert({
    'batch_id': batchId,
    'subject_id': subjectId,
  });
}

@override
Future<void> removeSubjectFromBatch({
  required String batchId,
  required String subjectId,
}) async {
  await supabase
      .from('batch_subjects')
      .delete()
      .eq(
        'batch_id',
        batchId,
      )
      .eq(
        'subject_id',
        subjectId,
      );
}
}

