import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_stat_card.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Continue your review journey',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
  builder: (context, constraints) {
    int crossAxisCount = 4;

    if (constraints.maxWidth < 1200) {
      crossAxisCount = 2;
    }

    if (constraints.maxWidth < 700) {
      crossAxisCount = 1;
    }

    return GridView.count(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisCount:
          crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: const [
        DashboardStatCard(
          title: 'Study Streak',
          value: '12 Days',
          icon:
              Icons.local_fire_department,
        ),
        DashboardStatCard(
          title: 'Subjects',
          value: '8',
          icon: Icons.menu_book,
        ),
        DashboardStatCard(
          title: 'Quizzes',
          value: '45',
          icon: Icons.quiz,
        ),
        DashboardStatCard(
          title: 'Average',
          value: '91%',
          icon: Icons.trending_up,
        ),
      ],
    );
  },
),

          const SizedBox(height: 32),

          Text(
            'Recent Materials',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: const [
                ListTile(
                  leading:
                      Icon(Icons.description),
                  title: Text(
                    'Anatomy Reviewer.pdf',
                  ),
                  subtitle:
                      Text('Uploaded recently'),
                ),
                Divider(height: 1),
                ListTile(
                  leading:
                      Icon(Icons.description),
                  title: Text(
                    'Pharmacology Notes.pdf',
                  ),
                  subtitle:
                      Text('Uploaded recently'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Upcoming Exams',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.quiz),
                  title:
                      Text('Mock Exam #1'),
                  subtitle:
                      Text('100 Questions'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.quiz),
                  title:
                      Text('Final Preboard'),
                  subtitle:
                      Text('200 Questions'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Performance Summary',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Average Score',
                  ),

                  SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: 0.91,
                  ),

                  SizedBox(height: 12),

                  Text(
                    '91%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}