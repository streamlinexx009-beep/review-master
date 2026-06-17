import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/topic_exam_service.dart';

class TopicExamScreen extends ConsumerWidget {
  final String topicId;

  const TopicExamScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topic Exam',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<
            Map<String, dynamic>?>(
          future:
              TopicExamService
                  .getExamByTopic(
            topicId,
          ),
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            final exam =
                snapshot.data;

            if (exam == null) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Topic Exam',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        'No exam available for this topic.',
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  exam['title'] ??
                      'Topic Exam',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Ready to test your knowledge?',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyLarge,
                ),

                const SizedBox(
                  height: 24,
                ),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          exam['title'],
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleLarge,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'This exam is linked to the selected topic.',
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        SizedBox(
                          width:
                              double
                                  .infinity,
                          child:
                              FilledButton
                                  .icon(
                            onPressed:
                                () {
                              context.go(
                                '/take-topic-exam/${exam['id']}',
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .play_arrow,
                            ),
                            label:
                                const Text(
                              'Start Exam',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}