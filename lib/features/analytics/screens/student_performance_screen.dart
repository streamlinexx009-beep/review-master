import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_provider.dart';

class StudentPerformanceScreen extends ConsumerWidget {
  const StudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analyticsSummaryProvider);
    final topicPerformance = ref.watch(topicPerformanceProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Performance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor scores, pass rate, topic progress, and learning performance.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  summary.when(
                    data: (data) => LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 900;
                        final cards = [
                          _PerformanceCard(
                            title: 'Average Score',
                            value: '${data.overallAverage.toStringAsFixed(0)}%',
                            icon: Icons.trending_up,
                          ),
                          _PerformanceCard(
                            title: 'Best Score',
                            value: '${data.bestScore.toStringAsFixed(0)}%',
                            icon: Icons.emoji_events_outlined,
                          ),
                          _PerformanceCard(
                            title: 'Pass Rate',
                            value: '${data.passRate.toStringAsFixed(0)}%',
                            icon: Icons.check_circle_outline,
                          ),
                          _PerformanceCard(
                            title: 'Activities Taken',
                            value: data.totalQuizzes.toString(),
                            icon: Icons.assignment_outlined,
                          ),
                        ];

                        if (isNarrow) {
                          return Column(
                            children: cards
                                .map(
                                  (card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return Row(
                          children: cards
                              .map(
                                (card) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: card,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Topic Performance',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          topicPerformance.when(
                            data: (topics) {
                              if (topics.isEmpty) {
                                return const Text('No student performance data available yet.');
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Topic')),
                                    DataColumn(label: Text('Average Score')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  rows: topics.map((topic) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(topic.topicName)),
                                        DataCell(Text('${topic.averageScore.toStringAsFixed(0)}%')),
                                        DataCell(Text(topic.masteryLevel)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(e.toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _PerformanceCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(height: 18),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}
