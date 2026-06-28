import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subject_provider.dart';

class SubjectDetailsScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectProvider(subjectId));

    return subject.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (data) {
        if (data == null) {
          return const Center(child: Text('Class not found'));
        }

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF7F64), Color(0xFFFF9A76)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.description ?? 'No section',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => context.go('/subjects/$subjectId/materials'),
                          icon: const Icon(Icons.folder_outlined),
                          label: const Text('Materials'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => context.go('/flashcards'),
                          icon: const Icon(Icons.style_outlined),
                          label: const Text('Flashcards'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => context.go('/exams'),
                          icon: const Icon(Icons.quiz_outlined),
                          label: const Text('Exams'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => context.go('/results'),
                          icon: const Icon(Icons.assessment_outlined),
                          label: const Text('Results'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  tabs: [
                    Tab(text: 'Stream'),
                    Tab(text: 'Modules'),
                    Tab(text: 'People'),
                    Tab(text: 'Results'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _StreamTab(subjectId: subjectId),
                    _ModulesTab(subjectId: subjectId),
                    const _PeopleTab(),
                    const _ResultsTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreamTab extends StatelessWidget {
  final String subjectId;

  const _StreamTab({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Announce something to your class'),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.school)),
            title: const Text('Welcome to your class stream'),
            subtitle: const Text('Announcements and updates will appear here.'),
          ),
        ),
      ],
    );
  }
}

class _ModulesTab extends StatelessWidget {
  final String subjectId;

  const _ModulesTab({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Subject Module',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Materials, flashcards, exams, and results are now accessed from inside this subject.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
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
              childAspectRatio: 1.35,
              children: [
                _ModuleCard(
                  title: 'Materials',
                  subtitle: 'PDFs, notes, and learning resources',
                  icon: Icons.folder_outlined,
                  onTap: () => context.go('/subjects/$subjectId/materials'),
                ),
                _ModuleCard(
                  title: 'Flashcards',
                  subtitle: 'Review key terms and concepts',
                  icon: Icons.style_outlined,
                  onTap: () => context.go('/flashcards'),
                ),
                _ModuleCard(
                  title: 'Exams',
                  subtitle: 'Create and manage assessments',
                  icon: Icons.quiz_outlined,
                  onTap: () => context.go('/exams'),
                ),
                _ModuleCard(
                  title: 'Results',
                  subtitle: 'Scores and class performance records',
                  icon: Icons.assessment_outlined,
                  onTap: () => context.go('/results'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/subjects/$subjectId/topics'),
              icon: const Icon(Icons.add),
              label: const Text('Create topic'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/subjects/$subjectId/upload-material'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload material'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: Icon(icon),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleTab extends StatelessWidget {
  const _PeopleTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        ListTile(
          leading: Icon(Icons.people_outline),
          title: Text('People'),
          subtitle: Text('Teachers and students will be listed here.'),
        ),
      ],
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        ListTile(
          leading: Icon(Icons.grade_outlined),
          title: Text('Results'),
          subtitle: Text('Student scores and performance will appear here.'),
        ),
      ],
    );
  }
}
