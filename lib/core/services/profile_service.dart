import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService._();

  static final _client =
      Supabase.instance.client;

  static Future<String?> getUserRole() async {
    final user =
        _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final profile =
        await _client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

    return profile['role']
        as String?;
  }
}