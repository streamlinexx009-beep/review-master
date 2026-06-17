import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flashcard_provider.dart';
import 'study_flashcards_screen.dart';

class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final flashcards = ref.watch(
      flashcardsProvider,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Flashcards',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Review and memorize key concepts',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),

          const SizedBox(height: 24),

          Expanded(
            child: flashcards.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No flashcards available',
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
                            1.4,
                      ),
                      itemBuilder:
                          (_, index) {
                        final flashcard =
                            items[index];

                        return Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration:
                                      BoxDecoration(
                                    color: Theme.of(
                                            context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.style,
                                    color: Theme.of(
                                            context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                Text(
                                  flashcard
                                      .frontText,
                                  style:
                                      Theme.of(
                                              context)
                                          .textTheme
                                          .titleMedium,
                                  maxLines: 3,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),

                                const Spacer(),

                                SizedBox(
                                  width:
                                      double.infinity,
                                  child:
                                      FilledButton
                                          .tonal(
                                    onPressed:
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  StudyFlashcardsScreen(
                                            flashcards:
                                                items,
                                          ),
                                        ),
                                      );
                                    },
                                    child:
                                        const Text(
                                      'Study',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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