import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/supabase_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey:
        SupabaseConstants.supabaseAnonKey,
  );

runApp(
  const ProviderScope(
    child: ReviewHubApp(),
  ),
);
}

class ReviewHubApp extends StatelessWidget {
  const ReviewHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ReviewHub',

      debugShowCheckedModeBanner:
          false,

      theme: AppTheme.light(),

      routerConfig: appRouter,
    );
  }
}