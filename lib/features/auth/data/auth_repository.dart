import '../models/profile_model.dart';

abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> forgotPassword(
    String email,
  );

  Future<void> logout();

  Future<ProfileModel?> getProfile();
}