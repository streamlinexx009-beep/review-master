import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class RegisterForm
    extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm>
      createState() =>
          _RegisterFormState();
}

class _RegisterFormState
    extends ConsumerState<RegisterForm> {

  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> register() async {
    try {
      setState(() => loading = true);

      await ref
          .read(authRepositoryProvider)
          .register(
            fullName:
                fullNameController.text.trim(),
            email:
                emailController.text.trim(),
            password:
                passwordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful.',
          ),
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
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
        controller:
            fullNameController,
        decoration:
            const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(
            Icons.person_outline,
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller:
            emailController,
        keyboardType:
            TextInputType.emailAddress,
        decoration:
            const InputDecoration(
          labelText: 'Email Address',
          prefixIcon: Icon(
            Icons.email_outlined,
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller:
            passwordController,
        obscureText: true,
        decoration:
            const InputDecoration(
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
              loading ? null : register,
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
                  'Create Account',
                ),
        ),
      ),

      const SizedBox(height: 16),

      TextButton(
        onPressed: () {
          context.go('/login');
        },
        child: const Text(
          'Already have an account? Sign In',
        ),
      ),
    ],
  );
}
}