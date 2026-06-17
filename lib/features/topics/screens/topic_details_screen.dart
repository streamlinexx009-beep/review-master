import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/topic_provider.dart';
import '../../analytics/providers/topic_mastery_provider.dart';

class TopicDetailsScreen
    extends ConsumerWidget {
  final String topicId;

  const TopicDetailsScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final topic =
        ref.watch(
      topicProvider(topicId),
    );

    final mastery =
    ref.watch(
  topicMasteryProvider(topicId),
);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topic Details',
        ),
      ),
      body: topic.when(
        data: (item) {
          if (item == null) {
            return const Center(
              child: Text(
                'Topic not found',
              ),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  item.description ??
                      'No description available',
                ),

                const SizedBox(
                  height: 32,
                ),

                const Text(
                  'Learning Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _FeatureCard(
                        icon: Icons.description,
                        title: 'Summary',
                        subtitle: 'Review notes',
                        onTap: () {
                            context.go(
                            '/topics/$topicId/summary',
                            );
                        },
                    ),

                    _FeatureCard(
                        icon: Icons.style,
                        title: 'Flashcards',
                        subtitle: 'Practice recall',
                        onTap: () {
                            context.go(
                            '/topics/$topicId/flashcards',
                            );
                        },
                    ),

                    _FeatureCard(
                        icon: Icons.quiz,
                        title: 'Quiz',
                        subtitle: 'Test knowledge',
                        onTap: () {
                            context.go(
                            '/topics/$topicId/quiz',
                            );
                        },
                    ),

                    _FeatureCard(
                      icon: Icons.assignment,
                      title: 'Exam',
                      subtitle: 'Take assessment',
                      onTap: () {
                        context.go(
                          '/topics/$topicId/exam',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(
  height: 32,
),

const Text(
  'Practice Center',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 16,
),

Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    _FeatureCard(
      icon: Icons.auto_awesome,
      title: 'Practice Quiz',
      subtitle: 'Generate new questions',
      onTap: () {
        context.go(
          '/topics/$topicId/practice',
        );
      },
    ),

    _FeatureCard(
  icon: Icons.history,
  title: 'Practice History',
  subtitle: 'View past attempts',
  onTap: () {
    context.go(
      '/topics/$topicId/practice/history',
    );
  },
),
  ],
),



                const SizedBox(
                  height: 32,
                ),

                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                mastery.when(
  data: (data) {
    final flashcards =
        ((data?['flashcard_mastery'] ?? 0) as num)
            .toDouble();

    final quiz =
        ((data?['quiz_mastery'] ?? 0) as num)
            .toDouble();

    final exam =
        ((data?['exam_mastery'] ?? 0) as num)
            .toDouble();

    final practice =
        ((data?['practice_mastery'] ?? 0) as num)
            .toDouble();

    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.style),
            title: const Text('Flashcards'),
            subtitle: Text(
              '${flashcards.toStringAsFixed(0)}%',
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quiz'),
            subtitle: Text(
              '${quiz.toStringAsFixed(0)}%',
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Exam'),
            subtitle: Text(
              '${exam.toStringAsFixed(0)}%',
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Practice'),
            subtitle: Text(
              '${practice.toStringAsFixed(0)}%',
            ),
          ),
        ),
      ],
    );
  },
  loading: () => const Center(
    child: CircularProgressIndicator(),
  ),
  error: (e, _) => Text(
    'Error loading progress: $e',
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

class _FeatureCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  subtitle,
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}