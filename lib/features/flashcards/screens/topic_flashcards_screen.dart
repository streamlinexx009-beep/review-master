import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/topic_flashcards_provider.dart';
import 'study_flashcards_screen.dart';

class TopicFlashcardsScreen extends ConsumerWidget {
  final String topicId;

  const TopicFlashcardsScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final flashcards = ref.watch(
      topicFlashcardsProvider(
        topicId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flashcards',
        ),
      ),
      body: flashcards.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No flashcards found',
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(
                      Icons.school,
                    ),
                    label: const Text(
                      'Start Study Mode',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudyFlashcardsScreen(
                            flashcards: items,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  itemCount:
                      items.length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                    final card =
                        items[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        title: Text(
                          card.frontText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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