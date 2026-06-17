import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/material_provider.dart';
import '../widgets/material_card.dart';

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final materials = ref.watch(
      materialsProvider,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Materials',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Browse and manage your review materials',
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
                      'No materials available',
                    ),
                  );
                }

                return LayoutBuilder(
                  builder:
                      (context, constraints) {

                    int crossAxisCount = 4;

                    if (constraints.maxWidth <
                        1400) {
                      crossAxisCount = 3;
                    }

                    if (constraints.maxWidth <
                        1000) {
                      crossAxisCount = 2;
                    }

                    if (constraints.maxWidth <
                        700) {
                      crossAxisCount = 1;
                    }

                    return GridView.builder(
                      itemCount:
                          items.length,

                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            crossAxisCount,
                        crossAxisSpacing:
                            16,
                        mainAxisSpacing:
                            16,
                        childAspectRatio:
                            1.8,
                      ),

                      itemBuilder:
                          (_, index) {
                        return MaterialCard(
                          material:
                              items[index],
                        );
                      },
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