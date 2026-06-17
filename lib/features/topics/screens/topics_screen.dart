import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/topic_provider.dart';
import 'package:go_router/go_router.dart';

class TopicsScreen extends ConsumerWidget {
  final String subjectId;

  const TopicsScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final topics =
        ref.watch(
      topicsProvider(subjectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topics',
        ),
      ),
      body: topics.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No topics found',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder:
                (context, index) {
              final topic =
                  items[index];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  title: Text(
                    topic.name,
                  ),
                  subtitle: Text(
                    topic.description ?? '',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    context.go(
                      '/topics/${topic.id}',
                    );
                  },
                ),
              );
            },
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