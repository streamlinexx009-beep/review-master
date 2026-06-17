
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subject_provider.dart';
import 'edit_subject_screen.dart';

class SubjectDetailsScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final subject = ref.watch(
      subjectProvider(subjectId),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: subject.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text(
                'Subject not found',
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  data.description ??
                      'No description available',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditSubjectScreen(
                              subject: data,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                      ),
                      label: const Text(
                        'Edit Subject',
                      ),
                    ),

                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final confirmed =
                            await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Delete Subject',
                              ),
                              content: const Text(
                                'Are you sure you want to delete this subject?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },
                                  child: const Text(
                                    'Cancel',
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },
                                  child: const Text(
                                    'Delete',
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed != true) {
                          return;
                        }

                        await ref
                            .read(
                              subjectRepositoryProvider,
                            )
                            .deleteSubject(
                              data.id,
                            );

                        ref.invalidate(
                          subjectsProvider,
                        );

                        if (context.mounted) {
                          context.go('/subjects');
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                      ),
                      label: const Text(
                        'Delete Subject',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Subject Workspace',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    int crossAxisCount = 4;

                    if (constraints.maxWidth <
                        1200) {
                      crossAxisCount = 2;
                    }

                    if (constraints.maxWidth <
                        700) {
                      crossAxisCount = 1;
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _FeatureCard(
                          title: 'Materials',
                          icon:
                              Icons.description,
                          onTap: () {
                            context.go(
                              '/subjects/$subjectId/materials',
                            );
                          },
                        ),

                        _FeatureCard(
                          title: 'Flashcards',
                          icon: Icons.style,
                          onTap: () {
                            context.go(
                              '/flashcards',
                            );
                          },
                        ),

                        _FeatureCard(
                          title: 'Exams',
                          icon: Icons.quiz,
                          onTap: () {
                            context.go(
                              '/exams',
                            );
                          },
                        ),

                        _FeatureCard(
                          title: 'Analytics',
                          icon:
                              Icons.analytics,
                          onTap: () {
                            context.go(
                              '/analytics',
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                Text(
                  'Quick Overview',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Materials',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Upload and organize review PDFs, notes, and learning resources.',
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Text(
                          'Flashcards',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Review key concepts and memorize important topics.',
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Text(
                          'Exams',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Take mock exams and practice assessments.',
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Text(
                          'Analytics',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Track performance, scores, and learning progress.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },

        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (e, _) =>
            Center(
          child: Text(
            e.toString(),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    BoxDecoration(
                  color: Theme.of(
                          context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(
                          context)
                      .colorScheme
                      .primary,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

