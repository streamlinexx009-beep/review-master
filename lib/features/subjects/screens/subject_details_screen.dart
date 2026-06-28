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
                _ClassHeader(
                  name: data.name,
                  description: data.description,
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
                      Tab(icon: Icon(Icons.campaign_outlined), text: 'Class Feed'),
                      Tab(icon: Icon(Icons.auto_stories_outlined), text: 'Learning'),
                      Tab(icon: Icon(Icons.people_outline), text: 'Students'),
                      Tab(icon: Icon(Icons.assessment_outlined), text: 'Scores'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: TabBarView(
                    children: [
                      const _ClassFeedTab(),
                      _LearningTab(subjectId: subjectId),
                      const _StudentsTab(),
                      const _ScoresTab(),
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

class _ClassHeader extends StatelessWidget {
  final String name;
  final String? description;

  const _ClassHeader({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Class Workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description ?? 'Class details not added yet',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
              ),
              const SizedBox(height: 18),
              const Text(
                'Use the tabs below: post updates, add learning activities, view students, and check scores.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassFeedTab extends StatelessWidget {
  const _ClassFeedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SectionIntro(
          title: 'Class Feed',
          subtitle: 'Post reminders and announcements students can easily understand.',
          icon: Icons.campaign_outlined,
          color: const Color(0xFF0F766E),
        ),
        const SizedBox(height: 16),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFCCFBF1),
                child: Icon(Icons.edit_note_rounded, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post a class update', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Share instructions, reminders, or announcements with your class.'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Post Update'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _FriendlyNote(
          icon: Icons.info_outline_rounded,
          title: 'No updates yet',
          message: 'Class announcements and reminders will appear here once posted.',
        ),
      ],
    );
  }
}

class _LearningTab extends StatelessWidget {
  final String subjectId;

  const _LearningTab({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionIntro(
                title: 'Learning',
                subtitle: 'Choose what you want to prepare or review for this class.',
                icon: Icons.auto_stories_outlined,
                color: Color(0xFF0EA5E9),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => context.go('/subjects/$subjectId/topics'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Topic'),
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
              childAspectRatio: 1.05,
              children: [
                _LearningActionCard(
                  title: 'Learning Files',
                  shortLabel: 'Upload or open PDFs',
                  description: 'Use this for handouts, reviewers, modules, and lecture notes.',
                  icon: Icons.folder_outlined,
                  color: const Color(0xFF0EA5E9),
                  primaryLabel: 'Open Files',
                  onPrimary: () => context.go('/subjects/$subjectId/materials'),
                  secondaryLabel: 'Upload File',
                  onSecondary: () => context.go('/subjects/$subjectId/upload-material'),
                ),
                _LearningActionCard(
                  title: 'Review Cards',
                  shortLabel: 'Quick memorization',
                  description: 'Use this for terms, definitions, formulas, and short recall practice.',
                  icon: Icons.style_outlined,
                  color: const Color(0xFF8B5CF6),
                  primaryLabel: 'Open Cards',
                  onPrimary: () => context.go('/flashcards'),
                ),
                _LearningActionCard(
                  title: 'Tests',
                  shortLabel: 'Quizzes and exams',
                  description: 'Use this to create assessments and let students answer them.',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFFF97316),
                  primaryLabel: 'Open Tests',
                  onPrimary: () => context.go('/exams'),
                ),
                _LearningActionCard(
                  title: 'Scores',
                  shortLabel: 'Results and feedback',
                  description: 'Use this to review submitted attempts, scores, and performance.',
                  icon: Icons.assessment_outlined,
                  color: const Color(0xFF10B981),
                  primaryLabel: 'Open Scores',
                  onPrimary: () => context.go('/results'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _SectionIntro(
          title: 'Students',
          subtitle: 'View the people connected to this class.',
          icon: Icons.people_outline,
          color: Color(0xFF6366F1),
        ),
        SizedBox(height: 16),
        _FriendlyNote(
          icon: Icons.groups_outlined,
          title: 'Class list',
          message: 'Teachers and enrolled students will be listed here once the class enrollment view is connected.',
        ),
      ],
    );
  }
}

class _ScoresTab extends StatelessWidget {
  const _ScoresTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SectionIntro(
          title: 'Scores',
          subtitle: 'Check student results and progress without leaving the class workspace.',
          icon: Icons.assessment_outlined,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.analytics_outlined, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Performance and results'),
                    SizedBox(height: 4),
                    Text('Open the results page or student performance monitor to review submitted work.'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/results'),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Scores'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionIntro({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningActionCard extends StatelessWidget {
  final String title;
  final String shortLabel;
  final String description;
  final IconData icon;
  final Color color;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _LearningActionCard({
    required this.title,
    required this.shortLabel,
    required this.description,
    required this.icon,
    required this.color,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Text(shortLabel, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Expanded(child: Text(description, style: const TextStyle(color: Color(0xFF64748B), height: 1.35))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: FilledButton(onPressed: onPrimary, child: Text(primaryLabel))),
                  if (secondaryLabel != null && onSecondary != null) ...[
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!))),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendlyNote extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _FriendlyNote({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(message),
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
