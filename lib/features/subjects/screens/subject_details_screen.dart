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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Column(
                  children: [
                    _ClassHeader(
                      name: data.name,
                      description: data.description,
                    ),
                    const SizedBox(height: 30),
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
      padding: const EdgeInsets.fromLTRB(32, 30, 32, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2214B8A6),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: 24,
            child: Icon(
              Icons.school_rounded,
              color: Colors.white.withOpacity(0.12),
              size: 164,
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
              const SizedBox(height: 18),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description ?? 'Class details not added yet',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Text(
                  'Start with one tab below: post updates, add learning activities, view students, or check scores.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.35),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.55)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x180F172A),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: TabBar(
                    labelColor: Color(0xFF0F766E),
                    unselectedLabelColor: Color(0xFF64748B),
                    indicatorColor: Color(0xFF0F766E),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(icon: Icon(Icons.campaign_outlined), text: 'Class Feed'),
                      Tab(icon: Icon(Icons.auto_stories_outlined), text: 'Learning'),
                      Tab(icon: Icon(Icons.people_outline), text: 'Students'),
                      Tab(icon: Icon(Icons.assessment_outlined), text: 'Scores'),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SectionIntro(
          title: 'Class Feed',
          subtitle: 'Post reminders and announcements students can easily understand.',
          icon: Icons.campaign_outlined,
          color: const Color(0xFF0F766E),
        ),
        const SizedBox(height: 24),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFCCFBF1),
                child: Icon(Icons.edit_note_rounded, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post a class update', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text('Share instructions, reminders, or announcements with your class.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Post Update'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SectionIntro(
          title: 'Learning',
          subtitle: 'Choose one activity to prepare or review. Each card has a clear action for teachers and students.',
          icon: Icons.auto_stories_outlined,
          color: const Color(0xFF0EA5E9),
          trailing: FilledButton.icon(
            onPressed: () => context.go('/subjects/$subjectId/topics'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Topic'),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            var count = 2;
            if (constraints.maxWidth < 820) count = 1;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: constraints.maxWidth < 820 ? 2.2 : 2.35,
              children: [
                _LearningActionCard(
                  title: 'Learning Files',
                  shortLabel: 'PDFs and handouts',
                  description: 'Handouts, reviewers, modules, and lecture notes for this class.',
                  icon: Icons.folder_outlined,
                  color: const Color(0xFF0EA5E9),
                  primaryLabel: 'Open Files',
                  onPrimary: () => context.go('/subjects/$subjectId/materials'),
                  secondaryLabel: 'Upload File',
                  onSecondary: () => context.go('/subjects/$subjectId/upload-material'),
                ),
                _LearningActionCard(
                  title: 'Review Cards',
                  shortLabel: 'Quick review',
                  description: 'Terms, definitions, formulas, and short recall practice.',
                  icon: Icons.style_outlined,
                  color: const Color(0xFF8B5CF6),
                  primaryLabel: 'Open Cards',
                  onPrimary: () => context.go('/flashcards'),
                ),
                _LearningActionCard(
                  title: 'Tests',
                  shortLabel: 'Quizzes and exams',
                  description: 'Create assessments and let students answer them online.',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFFF97316),
                  primaryLabel: 'Open Tests',
                  onPrimary: () => context.go('/exams'),
                ),
                _LearningActionCard(
                  title: 'Scores',
                  shortLabel: 'Results and feedback',
                  description: 'Review submitted attempts, scores, and class performance.',
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
      padding: const EdgeInsets.only(bottom: 32),
      children: const [
        _SectionIntro(
          title: 'Students',
          subtitle: 'View the people connected to this class.',
          icon: Icons.people_outline,
          color: Color(0xFF6366F1),
        ),
        SizedBox(height: 24),
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
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionIntro(
          title: 'Scores',
          subtitle: 'Check student results and progress without leaving the class workspace.',
          icon: Icons.assessment_outlined,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 24),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.analytics_outlined, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Performance and results', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('Open the results page or student performance monitor to review submitted work.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 18),
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
  final Widget? trailing;

  const _SectionIntro({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 18),
            trailing!,
          ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(22)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Text(shortLabel, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: Text(description, style: const TextStyle(color: Color(0xFF64748B), height: 1.45))),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        SizedBox(width: 132, child: FilledButton(onPressed: onPrimary, child: Text(primaryLabel))),
                        if (secondaryLabel != null && onSecondary != null) ...[
                          const SizedBox(width: 12),
                          SizedBox(width: 132, child: OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!))),
                        ],
                      ],
                    ),
                  ],
                ),
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
        leading: CircleAvatar(radius: 24, child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(message, style: const TextStyle(height: 1.4)),
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22), child: child),
    );
  }
}
