import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subject_model.dart';
import 'subject_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SupabaseClient client;

  SubjectRepositoryImpl(this.client);

  @override
  Future<List<SubjectModel>> getSubjects() async {
    final data = await client.from('subjects').select().order('name');

    return data.map<SubjectModel>((e) => SubjectModel.fromMap(e)).toList();
  }

  @override
  Future<SubjectModel?> getSubjectById(String id) async {
    final data = await client
        .from('subjects')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return SubjectModel.fromMap(data);
  }

  @override
  Future<void> createSubject({
    required String name,
    String? description,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await client.from('subjects').insert({
      'name': name.trim(),
      'description': description?.trim(),
      'created_by': user.id,
    });
  }

  @override
  Future<SubjectModel> joinSubjectByCode(String code) async {
    final cleanedCode = code.trim().replaceAll(RegExp(r'\s+'), '');

    if (cleanedCode.isEmpty) {
      throw Exception('Enter a subject code.');
    }

    final joined = await client
        .rpc(
          'join_subject_by_code',
          params: {'p_join_code': cleanedCode},
        )
        .select()
        .single();

    final subjectId = joined['subject_id'] as String;
    final subject = await getSubjectById(subjectId);

    if (subject == null) {
      throw Exception('Subject joined, but details could not be loaded.');
    }

    return subject;
  }

  @override
  Future<void> updateSubject(SubjectModel subject) async {
    await client.from('subjects').update(subject.toMap()).eq('id', subject.id);
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await client.from('subjects').delete().eq('id', subjectId);
  }
}
