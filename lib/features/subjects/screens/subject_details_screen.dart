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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2214B8A6),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        bottom: -42,
                        child: Icon(
                          Icons.school_rounded,
                          color: Colors.white.withOpacity(0.12),
                          size: 170,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Text(
                                  'Subject Classroom',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.description ?? 'No section details yet',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _HeroAction(
                                icon: Icons.folder_outlined,
                                label: 'Materials',
                                onTap: () => context.go('/subjects/$subjectId/materials'),
                              ),
                              _HeroAction(
                                icon: Icons.style_outlined,
                                label: 'Flashcards',
                                onTap: () => context.go('/flashcards'),
                              ),
                              _HeroAction(
                                icon: Icons.quiz_outlined,
                                label: 'Exams',
                                onTap: () => context.go('/exams'),
                              ),
                              _HeroAction(
                                icon: Icons.assessment_outlined,
                                label: 'Results',
                                onTap: () => context.go('/results'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const TabBar(
                    labelColor: Color(0xFF0F766E),
                    unselectedLabelColor: Color(0xFF64748B),
                    indicatorColor: Color(0xFF0F766E),
                    tabs: [
                      Tab(text: 'Stream'),
                      Tab(text: 'Modules'),
                      Tab(text: 'People'),
                      Tab(text: 'Results'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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
          ),
        );
      },
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamTab extends StatelessWidget {
  final String subjectId;

  const _StreamTab({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFCCFBF1),
                child: Icon(Icons.campaign_rounded, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Announce something to your class', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Post reminders, announcements, or learning updates here.'),
                  ],
                ),
              ),
              FilledButton(onPressed: () {}, child: const Text('Post')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ModernCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.school_rounded)),
            title: const Text('Welcome to your class stream'),
            subtitle: const Text('Class announcements and updates will appear here.'),
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
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject Modules', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Everything students need for this subject is grouped here.'),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.go('/subjects/$subjectId/topics'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create topic'),
            ),
          ],
        ),
        const SizedBox(height: 18),
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
              childAspectRatio: 1.2,
              children: [
                _ModuleCard(
                  title: 'Materials',
                  subtitle: 'Upload PDFs, handouts, and learning files.',
                  icon: Icons.folder_outlined,
                  color: const Color(0xFF0EA5E9),
                  onTap: () => context.go('/subjects/$subjectId/materials'),
                ),
                _ModuleCard(
                  title: 'Flashcards',
                  subtitle: 'Help students review key terms quickly.',
                  icon: Icons.style_outlined,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.go('/flashcards'),
                ),
                _ModuleCard(
                  title: 'Exams',
                  subtitle: 'Create, publish, and manage assessments.',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFFF97316),
                  onTap: () => context.go('/exams'),
                ),
                _ModuleCard(
                  title: 'Results',
                  subtitle: 'Review scores and assessment outcomes.',
                  icon: Icons.assessment_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () => context.go('/results'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.upload_file_rounded)),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Need to add a handout or lecture PDF? Upload learning material directly to this subject.'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/subjects/$subjectId/upload-material'),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload material'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
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
      children: const [
        _ModernCard(
          child: ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('People'),
            subtitle: Text('Teachers and enrolled students will be listed here.'),
          ),
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
      children: const [
        _ModernCard(
          child: ListTile(
            leading: Icon(Icons.grade_outlined),
            title: Text('Results'),
            subtitle: Text('Student scores and subject performance summaries will appear here.'),
          ),
        ),
      ],
    );
  }
}

class _ModernCard extends StatelessWidget {
  final Widget child;

  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}
