import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/material_model.dart';
import 'material_repository.dart';

class MaterialRepositoryImpl
    implements MaterialRepository {
  final SupabaseClient client;

  MaterialRepositoryImpl(
    this.client,
  );

  @override
  Future<List<MaterialModel>>
      getMaterials() async {
    final data =
        await client
            .from('materials')
            .select()
            .order(
              'created_at',
              ascending: false,
            );

    return data
        .map<MaterialModel>(
          (e) =>
              MaterialModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<List<MaterialModel>>
      getMaterialsBySubject(
    String subjectId,
  ) async {
    final data =
        await client
            .from('materials')
            .select()
            .eq(
              'subject_id',
              subjectId,
            )
            .order(
              'created_at',
              ascending: false,
            );

    return data
        .map<MaterialModel>(
          (e) =>
              MaterialModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<void> uploadMaterial({
    required String title,
    required String fileName,
    required String fileUrl,
    required String subjectId,
    String? description,
  }) async {
    final user =
        client.auth.currentUser!;

    await client
        .from('materials')
        .insert({
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': 'pdf',
      'uploaded_by': user.id,
    });
  }

  @override
  Future<void> deleteMaterial(
    String materialId,
  ) async {
    await client
        .from('materials')
        .delete()
        .eq(
          'id',
          materialId,
        );
  }
}