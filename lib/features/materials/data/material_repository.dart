import '../models/material_model.dart';

abstract class MaterialRepository {
  Future<List<MaterialModel>>
      getMaterials();

  Future<List<MaterialModel>>
      getMaterialsBySubject(
    String subjectId,
  );

  Future<void> uploadMaterial({
    required String title,
    required String fileName,
    required String fileUrl,
    required String subjectId,
    String? description,
  });

  Future<void> deleteMaterial(
    String materialId,
  );
}