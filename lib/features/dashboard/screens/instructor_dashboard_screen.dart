import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstructorDashboardScreen
    extends StatelessWidget {
  const InstructorDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Instructor Dashboard',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Manage students, subjects, quizzes, and examinations',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),

          const SizedBox(height: 24),

         Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    FilledButton.icon(
      onPressed: () {
        context.go('/subjects');
      },
      icon: const Icon(
        Icons.menu_book,
      ),
      label: const Text(
        'Manage Subjects',
      ),
    ),

    FilledButton.icon(
      onPressed: () {
        context.go('/materials');
      },
      icon: const Icon(
        Icons.picture_as_pdf,
      ),
      label: const Text(
        'Manage Materials',
      ),
    ),

    FilledButton.icon(
      onPressed: () {
        context.go('/create-subject');
      },
      icon: const Icon(
        Icons.add,
      ),
      label: const Text(
        'Create Subject',
      ),
    ),
  ],
),
          const SizedBox(height: 24),

          Expanded(
            child: LayoutBuilder(
              builder:
                  (context, constraints) {
                int crossAxisCount = 4;

                if (constraints.maxWidth <
                    1200) {
                  crossAxisCount = 2;
                }

                if (constraints.maxWidth <
                    700) {
                  crossAxisCount = 1;
                }

                return GridView.count(
                  crossAxisCount:
                      crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: const [
                    _InstructorCard(
                      title: 'Students',
                      value: '248',
                      icon: Icons.people,
                    ),
                    _InstructorCard(
                      title: 'Subjects',
                      value: '8',
                      icon: Icons.menu_book,
                    ),
                    _InstructorCard(
                      title: 'Quizzes',
                      value: '45',
                      icon: Icons.quiz,
                    ),
                    _InstructorCard(
                      title: 'Exams',
                      value: '12',
                      icon: Icons.assignment,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InstructorCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                icon,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const Spacer(),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}