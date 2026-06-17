import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
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
            'Admin Dashboard',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Manage users, subjects, reports, and analytics',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
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
                    _AdminCard(
                      title: 'Users',
                      value: '1,248',
                      icon: Icons.people,
                    ),
                    _AdminCard(
                      title: 'Subjects',
                      value: '32',
                      icon: Icons.menu_book,
                    ),
                    _AdminCard(
                      title: 'Reports',
                      value: '84',
                      icon: Icons.assessment,
                    ),
                    _AdminCard(
                      title: 'Analytics',
                      value: '92%',
                      icon: Icons.analytics,
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

class _AdminCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AdminCard({
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