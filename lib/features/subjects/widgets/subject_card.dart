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
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: () => context.go('/subjects/${subject.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 116,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF7F64),
                    Color(0xFFFF9A76),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -16,
                    bottom: -24,
                    child: Icon(
                      Icons.school,
                      color: Colors.white.withOpacity(0.18),
                      size: 104,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subject.description ?? 'No section',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: ColoredBox(color: Colors.white),
            ),
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Progress',
                    onPressed: () {},
                    icon: const Icon(Icons.trending_up),
                  ),
                  IconButton(
                    tooltip: 'Materials',
                    onPressed: () => context.go('/subjects/${subject.id}/materials'),
                    icon: const Icon(Icons.folder_outlined),
                  ),
                  IconButton(
                    tooltip: 'More',
                    onPressed: () => context.go('/subjects/${subject.id}'),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
