import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../models/profile_model.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    Supabase.instance.client,
  );
});

final authStateProvider =
    StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth
      .onAuthStateChange;
});

final profileProvider =
    FutureProvider<ProfileModel?>((ref) async {
  return ref
      .read(authRepositoryProvider)
      .getProfile();
});