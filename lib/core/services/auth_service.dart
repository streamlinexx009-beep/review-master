import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client =
      Supabase.instance.client;

  static User? get currentUser =>
    Supabase.instance.client.auth.currentUser;

  static bool get isLoggedIn =>
    currentUser != null;

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> resetPassword(
    String email,
  ) async {
    await _client.auth.resetPasswordForEmail(
      email,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Session? get session =>
      _client.auth.currentSession;
}