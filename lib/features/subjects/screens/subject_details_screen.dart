import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/profile_service.dart';
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
        if (data == null) return const Center(child: Text('Class not found'));

        return FutureBuilder<String?>(
          future: ProfileService.getUserRole(),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data;
            final isTeacher = role == 'instructor' || role == 'admin';

            return DefaultTabController(
              length: 4,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      children: [
                        _ClassHeader(
                          name: data.name,
                          description: data.description,
                          isTeacher: isTeacher,
                        ),
                        const SizedBox(height: 22),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _ClassFeedTab(isTeacher: isTeacher),
                              _LearningTab(subjectId: subjectId, isTeacher: isTeacher),
                              _StudentsTab(isTeacher: isTeacher),
                              _ScoresTab(isTeacher: isTeacher),
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
      },
    );
  }
}

class _ClassHeader extends StatelessWidget {
  final String name;
  final String? description;
  final bool isTeacher;

  const _ClassHeader({required this.name, required this.description, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x1A14B8A6), blurRadius: 22, offset: Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 20,
            child: Icon(Icons.school_rounded, color: Colors.white.withOpacity(0.10), size: 132),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(99)),
                child: Text(
                  isTeacher ? 'Teacher Class Workspace' : 'Student Class Workspace',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 32, height: 1.08, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                description ?? 'Class details not added yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.55)),
                  boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  final bool isTeacher;

  const _ClassFeedTab({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        _PlainSectionHeader(
          title: 'Class Feed',
          subtitle: isTeacher ? 'Post class reminders and announcements.' : 'Read class reminders and announcements from your teacher.',
        ),
        const SizedBox(height: 18),
        if (isTeacher)
          _ModernCard(
            child: Row(
              children: [
                const CircleAvatar(radius: 25, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.edit_note_rounded, color: Color(0xFF0F766E))),
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
                FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_rounded), label: const Text('Post Update')),
              ],
            ),
          ),
        if (isTeacher) const SizedBox(height: 18),
        _FriendlyNote(
          icon: Icons.info_outline_rounded,
          title: isTeacher ? 'No updates yet' : 'No teacher updates yet',
          message: isTeacher ? 'Class announcements and reminders will appear here once posted.' : 'Announcements and reminders from your teacher will appear here.',
        ),
      ],
    );
  }
}

class _LearningTab extends StatelessWidget {
  final String subjectId;
  final bool isTeacher;

  const _LearningTab({required this.subjectId, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        _LearningHeader(
          isTeacher: isTeacher,
          onAddTopic: () => context.go('/subjects/$subjectId/topics'),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final singleColumn = constraints.maxWidth < 820;

            return GridView.count(
              crossAxisCount: singleColumn ? 1 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 22,
              mainAxisSpacing: 22,
              childAspectRatio: singleColumn ? 2.45 : 2.65,
              children: [
                _LearningActivityCard(
                  title: 'Learning Files',
                  label: 'PDFs and handouts',
                  description: isTeacher ? 'Upload handouts, reviewers, modules, and lecture notes.' : 'Open handouts, reviewers, modules, and lecture notes from your teacher.',
                  icon: Icons.folder_outlined,
                  color: const Color(0xFF0EA5E9),
                  primaryLabel: 'Open Files',
                  onPrimary: () => context.go('/subjects/$subjectId/materials'),
                  secondaryLabel: isTeacher ? 'Upload File' : null,
                  onSecondary: isTeacher ? () => context.go('/subjects/$subjectId/upload-material') : null,
                ),
                _LearningActivityCard(
                  title: 'Review Cards',
                  label: 'Flashcards',
                  description: isTeacher ? 'Create manual flashcards or use AI to draft cards for review.' : 'Study flashcards prepared for this class.',
                  icon: Icons.style_outlined,
                  color: const Color(0xFF8B5CF6),
                  primaryLabel: 'Open Cards',
                  onPrimary: () => context.go('/flashcards'),
                  secondaryLabel: isTeacher ? 'Create Card' : null,
                  onSecondary: isTeacher ? () => _showCreateFlashcardDialog(context, subjectId) : null,
                  tertiaryLabel: isTeacher ? 'AI Generate' : null,
                  onTertiary: isTeacher ? () => context.go('/subjects/$subjectId/ai-tools') : null,
                ),
                _LearningActivityCard(
                  title: isTeacher ? 'Tests' : 'Tests to Take',
                  label: 'Exams and quizzes',
                  description: isTeacher ? 'Create a test manually or use AI to draft questions before saving.' : 'Open quizzes and exams assigned by your teacher.',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFFF97316),
                  primaryLabel: isTeacher ? 'Open Tests' : 'Take Tests',
                  onPrimary: () => context.go('/exams'),
                  secondaryLabel: isTeacher ? 'Create Test' : null,
                  onSecondary: isTeacher ? () => context.go('/create-exam') : null,
                  tertiaryLabel: isTeacher ? 'AI Generate' : null,
                  onTertiary: isTeacher ? () => context.go('/subjects/$subjectId/ai-tools') : null,
                ),
                _LearningActivityCard(
                  title: isTeacher ? 'Scores' : 'My Scores',
                  label: 'Results and feedback',
                  description: isTeacher ? 'Review submitted attempts, scores, and class performance.' : 'View your scores and answer feedback for this class.',
                  icon: Icons.assessment_outlined,
                  color: const Color(0xFF10B981),
                  primaryLabel: isTeacher ? 'Open Scores' : 'My Results',
                  onPrimary: () => context.go('/results'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showCreateFlashcardDialog(BuildContext context, String subjectId) {
    showDialog<void>(context: context, builder: (_) => _CreateFlashcardDialog(subjectId: subjectId));
  }
}

class _StudentsTab extends StatelessWidget {
  final bool isTeacher;

  const _StudentsTab({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        _PlainSectionHeader(
          title: isTeacher ? 'Students' : 'Class People',
          subtitle: isTeacher ? 'View and monitor students connected to this class.' : 'View your teacher and classmates for this class.',
        ),
        const SizedBox(height: 18),
        _FriendlyNote(
          icon: Icons.groups_outlined,
          title: isTeacher ? 'Class list' : 'People list',
          message: isTeacher ? 'Teachers and enrolled students will be listed here once connected.' : 'Your teacher and classmates will appear here once connected.',
        ),
      ],
    );
  }
}

class _ScoresTab extends StatelessWidget {
  final bool isTeacher;

  const _ScoresTab({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        _PlainSectionHeader(
          title: isTeacher ? 'Scores' : 'My Scores',
          subtitle: isTeacher ? 'Check student results and progress.' : 'Check your own scores and exam feedback.',
        ),
        const SizedBox(height: 18),
        _ModernCard(
          child: Row(
            children: [
              const CircleAvatar(radius: 25, backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.analytics_outlined, color: Color(0xFF16A34A))),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isTeacher ? 'Performance and results' : 'My result records', style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      isTeacher ? 'Open student performance monitoring or result records.' : 'Open your submitted exams, scores, and feedback.',
                      style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              FilledButton.icon(
                onPressed: () => context.go(isTeacher ? '/analytics' : '/results'),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(isTeacher ? 'Open Performance' : 'Open My Results'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningHeader extends StatelessWidget {
  final bool isTeacher;
  final VoidCallback onAddTopic;

  const _LearningHeader({required this.isTeacher, required this.onAddTopic});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _PlainSectionHeader(
            title: isTeacher ? 'Learning activities' : 'Class learning activities',
            subtitle: isTeacher ? 'Create, prepare, and review content for this class.' : 'Open the learning activities your teacher prepared.',
          ),
        ),
        if (isTeacher) ...[
          const SizedBox(width: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
            onPressed: onAddTopic,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Topic'),
          ),
        ],
      ],
    );
  }
}

class _PlainSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlainSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }
}

class _LearningActivityCard extends StatelessWidget {
  final String title;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;

  const _LearningActivityCard({
    required this.title,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tertiaryLabel,
    this.onTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                        ),
                        const SizedBox(width: 10),
                        _SoftPill(label: label),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.45))),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _PrimaryActionButton(label: primaryLabel, onPressed: onPrimary),
                        if (secondaryLabel != null && onSecondary != null) _SecondaryActionButton(label: secondaryLabel!, onPressed: onSecondary!),
                        if (tertiaryLabel != null && onTertiary != null) _SecondaryActionButton(label: tertiaryLabel!, onPressed: onTertiary!, icon: Icons.auto_awesome_rounded),
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

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const _SecondaryActionButton({required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: icon == null ? 140 : 150,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F766E), side: const BorderSide(color: Color(0xFF0F766E)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.add_rounded, size: icon == null ? 0 : 16),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  final String label;

  const _SoftPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _CreateFlashcardDialog extends StatefulWidget {
  final String subjectId;

  const _CreateFlashcardDialog({required this.subjectId});

  @override
  State<_CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<_CreateFlashcardDialog> {
  final frontController = TextEditingController();
  final backController = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    frontController.dispose();
    backController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final front = frontController.text.trim();
    final back = backController.text.trim();

    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both front and back text.')));
      return;
    }

    setState(() => saving = true);

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await client.from('flashcards').insert({
        'subject_id': widget.subjectId,
        'front_text': front,
        'back_text': back,
        'created_by': user.id,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flashcard created.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Flashcard'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontController, maxLines: 2, decoration: const InputDecoration(labelText: 'Front', hintText: 'Question, term, or concept', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: backController, maxLines: 4, decoration: const InputDecoration(labelText: 'Back', hintText: 'Answer or explanation', border: OutlineInputBorder())),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: saving ? null : _save,
          icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
          label: Text(saving ? 'Saving...' : 'Save Flashcard'),
        ),
      ],
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
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(message, style: const TextStyle(height: 1.4))),
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
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22), child: child),
    );
  }
}
