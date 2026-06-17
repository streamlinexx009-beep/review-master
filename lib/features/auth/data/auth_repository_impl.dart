import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl
    implements AuthRepository {

  final SupabaseClient client;

  AuthRepositoryImpl(this.client);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response =
        await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) return;

    await client.from('profiles').insert({
      'id': response.user!.id,
      'email': email,
      'full_name': fullName,
      'role': 'student',
    });
  }

  @override
  Future<void> forgotPassword(
    String email,
  ) async {
    await client.auth.resetPasswordForEmail(
      email,
    );
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<ProfileModel?> getProfile() async {
    final user =
        client.auth.currentUser;

    if (user == null) return null;

    final data =
        await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

    return ProfileModel.fromMap(data);
  }
}