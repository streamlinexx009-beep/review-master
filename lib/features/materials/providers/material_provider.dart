import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/material_repository.dart';
import '../data/material_repository_impl.dart';
import '../models/material_model.dart';

final materialRepositoryProvider =
    Provider<MaterialRepository>(
  (ref) {
    return MaterialRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final materialsProvider =
    FutureProvider<List<MaterialModel>>(
  (ref) async {
    return ref
        .read(
          materialRepositoryProvider,
        )
        .getMaterials();
  },
);

final materialsBySubjectProvider =
    FutureProvider.family<
        List<MaterialModel>,
        String>(
  (
    ref,
    subjectId,
  ) {
    return ref
        .read(
          materialRepositoryProvider,
        )
        .getMaterialsBySubject(
          subjectId,
        );
  },
);