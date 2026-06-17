import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subject_model.dart';
import 'subject_repository.dart';

class SubjectRepositoryImpl
    implements SubjectRepository {
  final SupabaseClient client;

  SubjectRepositoryImpl(
    this.client,
  );

  @override
  Future<List<SubjectModel>>
      getSubjects() async {
    final data =
        await client
            .from('subjects')
            .select()
            .order('name');

    return data
        .map<SubjectModel>(
          (e) =>
              SubjectModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<SubjectModel?> getSubjectById(
    String id,
  ) async {
    final data =
        await client
            .from('subjects')
            .select()
            .eq('id', id)
            .maybeSingle();

    if (data == null) {
      return null;
    }

    return SubjectModel.fromMap(
      data,
    );
  }

  @override
  Future<void> createSubject({
    required String name,
    String? description,
  }) async {
    final user =
        client.auth.currentUser;

    await client
        .from('subjects')
        .insert({
      'name': name,
      'description': description,
      'created_by': user!.id,
    });
  }

  @override
  Future<void> updateSubject(
    SubjectModel subject,
  ) async {
    await client
        .from('subjects')
        .update(subject.toMap())
        .eq('id', subject.id);
  }

  @override
  Future<void> deleteSubject(
    String subjectId,
  ) async {
    await client
        .from('subjects')
        .delete()
        .eq('id', subjectId);
  }
}