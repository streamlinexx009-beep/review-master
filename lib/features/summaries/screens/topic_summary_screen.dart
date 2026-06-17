import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/topic_summary_provider.dart';

class TopicSummaryScreen extends ConsumerWidget {
  final String topicId;

  const TopicSummaryScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final summaryAsync = ref.watch(
      topicSummaryProvider(topicId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary',
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            error.toString(),
          ),
        ),
        data: (summary) {
          if (summary == null) {
            return const Center(
              child: Text(
                'No summary available',
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Text(
                  summary.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}