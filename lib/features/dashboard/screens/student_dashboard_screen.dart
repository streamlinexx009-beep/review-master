import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/profile_service.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ProfileService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data;
        final isTeacher = role == 'instructor' || role == 'admin';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTeacher ? 'Teacher Dashboard' : 'Student Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isTeacher
                    ? 'Overview of your classes, student performance, and learning activities.'
                    : 'Overview of your classes, progress, and upcoming learning activities.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  var count = 4;
                  if (constraints.maxWidth < 1100) count = 2;
                  if (constraints.maxWidth < 650) count = 1;

                  return GridView.count(
                    crossAxisCount: count,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _DashboardCard(
                        title: isTeacher ? 'Classes' : 'My Classes',
                        value: 'Open',
                        icon: Icons.menu_book_outlined,
                        onTap: () => context.go('/subjects'),
                      ),
                      _DashboardCard(
                        title: isTeacher ? 'Student Performance' : 'My Progress',
                        value: 'View',
                        icon: Icons.analytics_outlined,
                        onTap: () => context.go('/analytics'),
                      ),
                      _DashboardCard(
                        title: 'Study Planner',
                        value: 'Plan',
                        icon: Icons.event_note_outlined,
                        onTap: () => context.go('/study-planner'),
                      ),
                      _DashboardCard(
                        title: isTeacher ? 'Batches' : 'Activities',
                        value: isTeacher ? 'Manage' : 'Continue',
                        icon: isTeacher ? Icons.groups_outlined : Icons.play_circle_outline,
                        onTap: () => isTeacher ? context.go('/batches') : context.go('/subjects'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Icon(isTeacher ? Icons.school_outlined : Icons.lightbulb_outline),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTeacher ? 'Start from your subjects' : 'Continue learning from your classes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isTeacher
                                  ? 'Open a subject to manage materials, flashcards, exams, results, and student progress.'
                                  : 'Open a class to access your materials, flashcards, exams, and results.',
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/subjects'),
                        child: const Text('Open Subjects'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Icon(icon)),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
