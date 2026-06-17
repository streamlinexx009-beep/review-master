
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_provider.dart';
import '../widgets/modern_stat_card.dart';
import '../widgets/performance_badge.dart';
import '../widgets/performance_chart.dart';

import '../../study_planner/providers/study_planner_controller.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analyticsSummaryProvider);
    final topicPerformance = ref.watch(topicPerformanceProvider);
    final topicMastery =
    ref.watch(
      topicMasteryProvider,
    );
    final recentResults = ref.watch(recentResultsProvider);
    final performanceHistory = ref.watch(performanceHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your performance and progress',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: summary.when(
              data: (data) => SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            children: [
                              _statCard('Average Score', '${data.overallAverage.toStringAsFixed(0)}%', Icons.trending_up),
                              const SizedBox(height: 16),
                              _statCard('Best Score', '${data.bestScore.toStringAsFixed(0)}%', Icons.emoji_events),
                              const SizedBox(height: 16),
                              _statCard('Pass Rate', '${data.passRate.toStringAsFixed(0)}%', Icons.check_circle),
                              const SizedBox(height: 16),
                              _statCard('Quizzes Taken', data.totalQuizzes.toString(), Icons.assignment),
                              const SizedBox(height: 16),
                              PerformanceBadge(category: data.performanceCategory),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _statCard('Average Score', '${data.overallAverage.toStringAsFixed(0)}%', Icons.trending_up)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _statCard('Best Score', '${data.bestScore.toStringAsFixed(0)}%', Icons.emoji_events)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _statCard('Pass Rate', '${data.passRate.toStringAsFixed(0)}%', Icons.check_circle)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _statCard('Quizzes Taken', data.totalQuizzes.toString(), Icons.assignment)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: PerformanceBadge(category: data.performanceCategory),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                       _sectionCard(
  context,
  'Topic Mastery',
  topicMastery.when(
    data: (topics) {
      if (topics.isEmpty) {
        return const Text(
          'No mastery data available.',
        );
      }

      return Column(
        children: topics.map((topic) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        topic.topicName,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                    Text(
                      '${topic.mastery.toStringAsFixed(0)}%',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                LinearProgressIndicator(
                  value:
                      topic.mastery /
                      100,
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
    loading: () =>
        const CircularProgressIndicator(),
    error: (e, _) =>
        Text(e.toString()),
  ),
),

const SizedBox(height: 24),

_sectionCard(
  context,
  'Learning Breakdown',
  topicMastery.when(
    data: (topics) {
      if (topics.isEmpty) {
        return const Text(
          'No learning data available.',
        );
      }

      return Column(
        children: topics.map((topic) {
          return Card(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topicName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _breakdownRow(
                    'Flashcards',
                    topic.flashcardMastery,
                  ),

                  _breakdownRow(
                    'Practice',
                    topic.practiceMastery,
                  ),

                  _breakdownRow(
                    'Quiz',
                    topic.quizMastery,
                  ),

                  _breakdownRow(
                    'Exam',
                    topic.examMastery,
                  ),

                  const Divider(),

                  _breakdownRow(
                    'Overall',
                    topic.mastery,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
    loading: () =>
        const CircularProgressIndicator(),
    error: (e, _) =>
        Text(e.toString()),
  ),
),
                        const SizedBox(height: 24),
_sectionCard(
  context,
  'Smart Recommendations',
  topicMastery.when(
    data: (topics) {
      if (topics.isEmpty) {
        return const Text(
          'No recommendations available.',
        );
      }

      final sorted = [...topics]
        ..sort(
          (a, b) =>
              a.mastery.compareTo(
            b.mastery,
          ),
        );

      return Column(
        children: sorted.take(5).map((topic) {
          String status;
          String recommendation;
          IconData icon;

          if (topic.mastery < 50) {
            status = 'Needs Attention';
            recommendation =
                'Review Summary • Flashcards • Practice Quiz';
            icon = Icons.warning_amber_rounded;
          } else if (topic.mastery < 80) {
            status = 'Improving';
            recommendation =
                  'Continue quizzes and practice sessions.';
            icon = Icons.trending_up;
          } else {
            status = 'Strong';
            recommendation =
                 'Maintain performance and challenge yourself with exams.';
            icon = Icons.check_circle;
          }

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: ListTile(
              leading: Icon(icon),
              title: Text(
                topic.topicName,
              ),
              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(status),
                  Text(recommendation),
                ],
              ),
              trailing: Text(
                '${topic.mastery.toStringAsFixed(0)}%',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      );
    },
    loading: () =>
        const CircularProgressIndicator(),
    error: (e, _) =>
        Text(e.toString()),
  ),
),

                        const SizedBox(height: 24),

                        _sectionCard(
                          context,
                          'Topic Progress Dashboard',
                          topicPerformance.when(
                            data: (topics) => DataTable(
                              columns: const [
                                DataColumn(label: Text('Topic')),
                                DataColumn(label: Text('Score')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: topics.map((topic) => DataRow(cells: [
                                DataCell(Text(topic.topicName)),
                                DataCell(Text('${topic.averageScore.toStringAsFixed(0)}%')),
                                DataCell(Text(topic.masteryLevel)),
                              ])).toList(),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(e.toString()),
                          ),
                        ),

                        const SizedBox(height: 24),

_sectionCard(
  context,
  '⚠ Topics Needing Attention',
  topicMastery.when(
    data: (topics) {
      final weakTopics = topics
          .where(
            (topic) => topic.mastery < 60,
          )
          .toList()
        ..sort(
          (a, b) => a.mastery.compareTo(
            b.mastery,
          ),
        );

      if (weakTopics.isEmpty) {
        return const Text(
          'Excellent! No weak topics detected.',
        );
      }

return Column(
  children: weakTopics.map((topic) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading: const Icon(
                Icons.warning_amber_rounded,
              ),
              title: Text(
                topic.topicName,
              ),
              subtitle: Text(
                topic.mastery < 40
                    ? 'Immediate review recommended'
                    : 'Additional practice recommended',
              ),
              trailing: Text(
                '${topic.mastery.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment:
                  Alignment.centerRight,
              child:
ElevatedButton.icon(
  onPressed: () async {
    try {
      await ref
          .read(
            studyPlannerControllerProvider,
          )
          .generateWeakTopicPlan(
            topic.topicName,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              '${topic.topicName} plan ready.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
    }
  },
  icon: const Icon(
    Icons.auto_fix_high,
  ),
  label: const Text(
    'Generate Study Plan',
  ),
),
            ),
          ],
        ),
      ),
    );
  }).toList(),
);
    },
    loading: () =>
        const CircularProgressIndicator(),
    error: (e, _) =>
        Text(e.toString()),
  ),
),

const SizedBox(height: 24),

                        _sectionCard(
                          context,
                          'Study Insights',
                          topicMastery.when(
  data: (topics) {
    if (topics.isEmpty) {
      return const Text(
        'No study insights available.',
      );
    }

    final strongest =
        topics.reduce(
      (a, b) =>
          a.mastery >
                  b.mastery
              ? a
              : b,
    );

    final weakest =
        topics.reduce(
      (a, b) =>
          a.mastery <
                  b.mastery
              ? a
              : b,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Strongest Topic: ${strongest.topicName} (${strongest.mastery.toStringAsFixed(0)}%)',
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          '⚠ Weakest Topic: ${weakest.topicName} (${weakest.mastery.toStringAsFixed(0)}%)',
        ),

        const SizedBox(
          height: 8,
        ),

        Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Text(
      weakest.mastery < 40
          ? '🚨 Immediate attention required.'
          : weakest.mastery < 60
              ? '🎯 Additional review recommended.'
              : '📚 Continue practicing.',
    ),

    const SizedBox(height: 12),

    const Text(
      'Recommended Actions:',
      style: TextStyle(
        fontWeight:
            FontWeight.bold,
      ),
    ),

    const SizedBox(height: 8),

    const Text('• Review Summary'),
    const Text('• Review Flashcards'),
    const Text('• Generate Practice Quiz'),
    const Text('• Retake Quiz'),
  ],
),
      ],
    );
  },
  loading: () =>
      const CircularProgressIndicator(),
  error: (e, _) =>
      Text(e.toString()),
),
                        ),

                        const SizedBox(height: 24),

                        _sectionCard(
                          context,
                          'Recent Quiz Results',
                          recentResults.when(
                            data: (results) => Column(
                              children: results.take(5).map((r) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(r.examTitle),
                                trailing: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    borderRadius:
        BorderRadius.circular(20),
    color: r.score >= 75
        ? Colors.green.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1),
  ),
  child: Text(
    '${r.score.toStringAsFixed(0)}%',
    style: TextStyle(
      color: r.score >= 75
          ? Colors.green
          : Colors.orange,
      fontWeight:
          FontWeight.bold,
    ),
  ),
),
                              )).toList(),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(e.toString()),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _sectionCard(
                          context,
                          'Performance Trend',
                          performanceHistory.when(
                            data: (history) => Column(
                              children: [
                                PerformanceChart(data: history),
                                const SizedBox(height: 12),
                                Text('Current average: ${data.overallAverage.toStringAsFixed(2)}%'),
                              ],
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(e.toString()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return SizedBox(
      height: 150,
      child: ModernStatCard(title: title, value: value, icon: icon),
    );
  }

  Widget _breakdownRow(
  String label,
  double value,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 4,
    ),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),

        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 50,
          child: Text(
            '${value.toStringAsFixed(0)}%',
          ),
        ),
      ],
    ),
  );
}

  Widget _sectionCard(BuildContext context, String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
