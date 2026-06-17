import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/profile_service.dart';

import '../providers/auth_provider.dart';

class LoginForm
    extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm>
      createState() => _LoginFormState();
}

class _LoginFormState
    extends ConsumerState<LoginForm> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      await ref
          .read(authRepositoryProvider)
          .login(
            email: emailController.text.trim(),
            password:
                passwordController.text,
          );

      if (!mounted) return;

    final role =
    await ProfileService.getUserRole();

if (!mounted) return;

switch (role) {
  case 'admin':
    context.go('/admin');
    break;

  case 'instructor':
    context.go('/instructor');
    break;

  default:
    context.go('/dashboard');
}
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: emailController,
        keyboardType:
            TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email Address',
          prefixIcon: Icon(
            Icons.email_outlined,
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(
            Icons.lock_outline,
          ),
        ),
      ),

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed:
              loading ? null : login,
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Sign In',
                ),
        ),
      ),

      const SizedBox(height: 12),

      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            context.go(
              '/forgot-password',
            );
          },
          child: const Text(
            'Forgot Password?',
          ),
        ),
      ),

      const Divider(height: 32),

      TextButton.icon(
        onPressed: () {
          context.go('/register');
        },
        icon: const Icon(
          Icons.person_add_alt_1,
        ),
        label: const Text(
          'Create Account',
        ),
      ),
    ],
  );
}
}