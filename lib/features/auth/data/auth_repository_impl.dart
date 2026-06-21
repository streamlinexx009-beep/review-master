import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  AuthRepositoryImpl(this.client);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    final response = await client.auth.signUp(
      email: normalizedEmail,
      password: password,
    );

    final user = response.user;
    if (user == null) return;

    await client.from('profiles').upsert({
      'id': user.id,
      'email': normalizedEmail,
      'full_name': fullName.trim(),
      'role': 'student',
    }, onConflict: 'id');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await client.auth.resetPasswordForEmail(email.trim());
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<ProfileModel?> getProfile() async {
    final user = client.auth.currentUser;

    if (user == null) return null;

    final data = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    return ProfileModel.fromMap(data);
  }
}
