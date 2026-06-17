import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/learning_content_provider.dart';

class SummaryScreen extends ConsumerWidget {
  final String topicId;

  const SummaryScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final contents = ref.watch(
      learningContentsProvider(
        topicId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary',
        ),
      ),
      body: contents.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No summaries found',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(
              16,
            ),
            itemCount: items.length,
            itemBuilder: (
              context,
              index,
            ) {
              final item =
                  items[index];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        item.title,
                        style:
                            Theme.of(context)
                                .textTheme
                                .titleLarge,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        item.content,
                      ),
                    ],
                  ),
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