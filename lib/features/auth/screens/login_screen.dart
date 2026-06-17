import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
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
                maxWidth: 460,
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
                          Icons.school_rounded,
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
                        'Review Master',
                        style:
                            Theme.of(context)
                                .textTheme
                                .headlineMedium,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Learning & Assessment Platform',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyLarge,
                        textAlign:
                            TextAlign.center,
                      ),

                      const SizedBox(
                        height: 32,
                      ),

                      const LoginForm(),

                      const SizedBox(
                        height: 24,
                      ),

                      Text(
                        'Empowering students to prepare smarter and perform better.',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                        textAlign:
                            TextAlign.center,
                      ),
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