import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  const SubjectCard({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Icon(
                Icons.menu_book,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subject.description ??
                        'No description available',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            FilledButton.tonal(
              onPressed: () {
                context.go(
                  '/subjects/${subject.id}/topics',
                );
              },
              child: const Text(
                'Open',
              ),
            ),
          ],
        ),
      ),
    );
  }
}