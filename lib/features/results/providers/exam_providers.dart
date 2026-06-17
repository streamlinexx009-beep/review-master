import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exams/providers/exam_provider.dart';

final myResultsProvider =
    FutureProvider((ref) {
  return ref
      .read(examRepositoryProvider)
      .getMyAttempts();
});