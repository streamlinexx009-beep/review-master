import 'package:flutter/material.dart';

import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8F0FE),
            ],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    40,
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration:
                            BoxDecoration(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primaryContainer,
                          shape:
                              BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 44,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primary,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      Text(
                        'Create Account',
                        style:
                            Theme.of(context)
                                .textTheme
                                .headlineMedium,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Start your review journey today',
                        textAlign:
                            TextAlign.center,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyLarge,
                      ),

                      const SizedBox(
                        height: 32,
                      ),

                      const RegisterForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}