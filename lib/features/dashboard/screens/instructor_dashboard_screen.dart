import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeacherHero(
                onOpenClasses: () => context.go('/subjects'),
                onViewPerformance: () => context.go('/analytics'),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 860;
                  return GridView.count(
                    crossAxisCount: twoColumns ? 2 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: twoColumns ? 2.8 : 3.4,
                    children: [
                      _TeacherActionCard(
                        title: 'Prepare class content',
                        description: 'Create learning files, flashcards, exams, quizzes, and AI-generated drafts inside each subject.',
                        icon: Icons.auto_stories_rounded,
                        color: const Color(0xFF0F766E),
                        buttonLabel: 'Open Subjects',
                        onTap: () => context.go('/subjects'),
                      ),
                      _TeacherActionCard(
                        title: 'Monitor students',
                        description: 'Choose a subject, select a student, and review performance analysis and exam attempts.',
                        icon: Icons.insights_rounded,
                        color: const Color(0xFF4F46E5),
                        buttonLabel: 'Student Performance',
                        onTap: () => context.go('/analytics'),
                      ),
                      _TeacherActionCard(
                        title: 'Plan learning tasks',
                        description: 'Create study plans with tasks, target dates, and progress tracking.',
                        icon: Icons.event_note_rounded,
                        color: const Color(0xFF0EA5E9),
                        buttonLabel: 'Open Planner',
                        onTap: () => context.go('/study-planner'),
                      ),
                      _TeacherActionCard(
                        title: 'Manage batches',
                        description: 'Organize students into groups and manage class batches without clutter.',
                        icon: Icons.groups_rounded,
                        color: const Color(0xFFF97316),
                        buttonLabel: 'Open Batches',
                        onTap: () => context.go('/batches'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherHero extends StatelessWidget {
  final VoidCallback onOpenClasses;
  final VoidCallback onViewPerformance;

  const _TeacherHero({required this.onOpenClasses, required this.onViewPerformance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A14B8A6), blurRadius: 26, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -48,
            child: Icon(Icons.school_rounded, size: 190, color: Colors.white.withOpacity(0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(99)),
                child: const Text('Teacher Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Welcome to your teaching dashboard',
                style: TextStyle(color: Colors.white, fontSize: 36, height: 1.1, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 780,
                child: Text(
                  'This workspace is for teachers only: create class content, generate AI drafts, manage batches, and monitor student progress.',
                  style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 16, height: 1.45),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
                    onPressed: onOpenClasses,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Open Classes'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.6)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
                    onPressed: onViewPerformance,
                    icon: const Icon(Icons.insights_rounded),
                    label: const Text('View Student Performance'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeacherActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String buttonLabel;
  final VoidCallback onTap;

  const _TeacherActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(22)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.tonal(onPressed: onTap, child: Text(buttonLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
