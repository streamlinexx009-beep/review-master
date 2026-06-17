import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/material_provider.dart';
import '../widgets/material_card.dart';

class SubjectMaterialsScreen
    extends ConsumerWidget {
  final String subjectId;

  const SubjectMaterialsScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final materials = ref.watch(
      materialsBySubjectProvider(
        subjectId,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Subject Materials',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: () {
                  context.go(
                    '/subjects/$subjectId/upload-material',
                  );
                },
                icon: const Icon(
                  Icons.upload_file,
                ),
                label: const Text(
                  'Upload Material',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Manage review materials for this subject',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),

          const SizedBox(height: 24),

          Expanded(
            child: materials.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No materials uploaded yet',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                      items.length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: MaterialCard(
                        material:
                            items[index],
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
          ),
        ],
      ),
    );
  }
}