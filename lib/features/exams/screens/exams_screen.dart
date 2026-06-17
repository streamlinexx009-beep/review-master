import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/exam_model.dart';
import '../providers/exam_provider.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final examsAsync =
        ref.watch(examsProvider);

    return Scaffold(
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          context.go('/create-exam');
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Create Exam',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Mock Exams',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Practice with simulated board examinations',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: examsAsync.when(
                data: (exams) {
                  if (exams.isEmpty) {
                    return const Center(
                      child: Text(
                        'No exams available',
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      int crossAxisCount = 3;

                      if (constraints.maxWidth <
                          1200) {
                        crossAxisCount = 2;
                      }

                      if (constraints.maxWidth <
                          700) {
                        crossAxisCount = 1;
                      }

                      return GridView.builder(
                        itemCount:
                            exams.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              crossAxisCount,
                          crossAxisSpacing:
                              16,
                          mainAxisSpacing:
                              16,
                          childAspectRatio:
                              1.2,
                        ),
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final exam =
                              exams[index];

                          return _ExamCard(
                            exam: exam,
                          );
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),
                error: (
                  error,
                  stackTrace,
                ) =>
                    Center(
                  child: Text(
                    error.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;

  const _ExamCard({
    required this.exam,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Icon(
                Icons.quiz,
                color: Theme.of(context)
                    .colorScheme
                    .tertiary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              exam.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              '${exam.timeLimit} minutes',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 4),

            Text(
              'Passing Score: ${exam.passingScore}%',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),

            const Spacer(),

            Column(
  children: [
    SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          context.go(
            '/take-exam/${exam.id}',
          );
        },
        child: const Text(
          'Start Exam',
        ),
      ),
    ),

    const SizedBox(
      height: 8,
    ),

    SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.go(
            '/create-question/${exam.id}',
          );
        },
        child: const Text(
          'Manage Questions',
        ),
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}