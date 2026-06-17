import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/results_providers.dart';
import 'result_details_screen.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final results = ref.watch(
      myResultsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Results',
        ),
      ),
      body: results.when(
        data: (attempts) {
          if (attempts.isEmpty) {
            return const Center(
              child: Text(
                'No exam attempts yet.',
              ),
            );
          }

          final totalAttempts =
              attempts.length;

          final passedCount =
              attempts
                  .where(
                    (a) => a.passed,
                  )
                  .length;

          final failedCount =
              totalAttempts -
                  passedCount;

          final averageScore =
              attempts
                      .map(
                        (a) => a.score,
                      )
                      .reduce(
                        (a, b) =>
                            a + b,
                      ) /
                  totalAttempts;

          return LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final isMobile =
                  constraints.maxWidth <
                      900;

              return SingleChildScrollView(
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
                      'Results Dashboard',
                      style: Theme.of(
                              context)
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Review your exam performance',
                      style: Theme.of(
                              context)
                          .textTheme
                          .bodyLarge,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    if (isMobile)
                      Column(
                        children: [
                          _StatCard(
                            title:
                                'Attempts',
                            value:
                                '$totalAttempts',
                            icon:
                                Icons.assignment,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _StatCard(
                            title:
                                'Passed',
                            value:
                                '$passedCount',
                            icon:
                                Icons.check_circle,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _StatCard(
                            title:
                                'Failed',
                            value:
                                '$failedCount',
                            icon:
                                Icons.cancel,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _StatCard(
                            title:
                                'Average',
                            value:
                                '${averageScore.toStringAsFixed(0)}%',
                            icon:
                                Icons.bar_chart,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Attempts',
                              value:
                                  '$totalAttempts',
                              icon:
                                  Icons.assignment,
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Passed',
                              value:
                                  '$passedCount',
                              icon:
                                  Icons.check_circle,
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Failed',
                              value:
                                  '$failedCount',
                              icon:
                                  Icons.cancel,
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Average',
                              value:
                                  '${averageScore.toStringAsFixed(0)}%',
                              icon:
                                  Icons.bar_chart,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(
                      height: 32,
                    ),

                    Text(
                      'Exam Attempts',
                      style: Theme.of(
                              context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          attempts.length,
                      itemBuilder:
                          (
                            context,
                            index,
                          ) {
                        final attempt =
                            attempts[
                                index];

                        return Card(
                          margin:
                              const EdgeInsets.only(
                            bottom:
                                16,
                          ),
                          child:
                              Padding(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          Text(
                                        attempt.examTitle ??
                                            'Exam Attempt',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),

                                    Chip(
                                      backgroundColor:
                                          attempt.passed
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      label:
                                          Text(
                                        attempt.passed
                                            ? 'PASSED'
                                            : 'FAILED',
                                        style:
                                            TextStyle(
                                          color: attempt.passed
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height:
                                      16,
                                ),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bar_chart,
                                    ),

                                    const SizedBox(
                                      width:
                                          8,
                                    ),

                                    Text(
                                      'Score: ${attempt.score.toStringAsFixed(2)}%',
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height:
                                      16,
                                ),

                                Align(
                                  alignment:
                                      Alignment.centerRight,
                                  child:
                                   TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                         builder: (_) =>
                                              ResultDetailsScreen(
                                            attemptId: attempt.id,
                                            examTitle:
                                                attempt.examTitle ??
                                                    'Exam Attempt',
                                            score: attempt.score,
                                            passed: attempt.passed,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                    ),
                                    label: const Text(
                                      'View Details',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading:
            () => const Center(
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
    );
  }
}

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              value,
              style: Theme.of(
                      context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              title,
            ),
          ],
        ),
      ),
    );
  }
}