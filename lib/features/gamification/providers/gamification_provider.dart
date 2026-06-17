import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/gamification_repository.dart';
import '../data/gamification_repository_impl.dart';

final gamificationRepositoryProvider =
    Provider<GamificationRepository>(
  (ref) {
    return GamificationRepositoryImpl(
      Supabase.instance.client,
    );
  },
);