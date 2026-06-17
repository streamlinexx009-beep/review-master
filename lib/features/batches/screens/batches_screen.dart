import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/batch_providers.dart';
import 'create_batch_screen.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final batchesAsync =
        ref.watch(
      batchesProvider,
    );

    return Padding(
      padding:
          const EdgeInsets.all(24),
      child: batchesAsync.when(
        loading:
            () => const Center(
          child:
              CircularProgressIndicator(),
        ),

        error:
            (error, stack) =>
                Center(
          child: Text(
            error.toString(),
          ),
        ),

        data: (batches) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
         Row(
  children: [
    Text(
      'Batches',
      style: Theme.of(context)
          .textTheme
          .headlineMedium,
    ),

    const Spacer(),

    FilledButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) =>
              const CreateBatchScreen(),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text(
        'Create Batch',
      ),
    ),
  ],
),

              const SizedBox(
                height: 24,
              ),

              if (batches.isEmpty)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.only(
                      top: 100,
                    ),
                    child: Text(
                      'No batches found.',
                    ),
                  ),
                )
              else
                Expanded(
                  child:
                      ListView.builder(
                    itemCount:
                        batches.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                      final batch =
                          batches[index];

                      return Card(
                        child: ListTile(
                          onTap: () {
                            context.go(
                              '/batches/${batch.id}',
                            );
                          },
                          title: Text(
                            batch.name,
                          ),
                          subtitle: Text(
                            batch.description ??
                                'No description',
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}