import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGuard {
  static bool isLoggedIn() {
    return Supabase
            .instance
            .client
            .auth
            .currentUser !=
        null;
  }
}