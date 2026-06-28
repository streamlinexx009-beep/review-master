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

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHero(isTeacher: isTeacher),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      var count = 4;
                      if (constraints.maxWidth < 1120) count = 2;
                      if (constraints.maxWidth < 680) count = 1;

                      return GridView.count(
                        crossAxisCount: count,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: count == 1 ? 3.6 : 1.5,
                        children: [
                          _ActionCard(
                            title: isTeacher ? 'My Classes' : 'My Classes',
                            subtitle: isTeacher ? 'Open subjects and manage class modules.' : 'Open your enrolled classes and activities.',
                            icon: Icons.menu_book_rounded,
                            color: const Color(0xFF0F766E),
                            buttonLabel: 'Open',
                            onTap: () => context.go('/subjects'),
                          ),
                          _ActionCard(
                            title: isTeacher ? 'Student Performance' : 'My Progress',
                            subtitle: isTeacher ? 'Monitor enrolled students and exam progress.' : 'Review your scores and learning progress.',
                            icon: Icons.insights_rounded,
                            color: const Color(0xFF4F46E5),
                            buttonLabel: 'View',
                            onTap: () => context.go('/analytics'),
                          ),
                          _ActionCard(
                            title: 'Study Planner',
                            subtitle: isTeacher ? 'Plan lessons, reviews, and learning schedules.' : 'Organize your study schedule and reminders.',
                            icon: Icons.event_note_rounded,
                            color: const Color(0xFF0EA5E9),
                            buttonLabel: 'Plan',
                            onTap: () => context.go('/study-planner'),
                          ),
                          _ActionCard(
                            title: isTeacher ? 'Batches' : 'Activities',
                            subtitle: isTeacher ? 'Manage class groups and enrolled students.' : 'Continue quizzes, materials, and class tasks.',
                            icon: isTeacher ? Icons.groups_rounded : Icons.play_circle_fill_rounded,
                            color: const Color(0xFFF97316),
                            buttonLabel: isTeacher ? 'Manage' : 'Continue',
                            onTap: () => isTeacher ? context.go('/batches') : context.go('/subjects'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 980;
                      final startPanel = _StartPanel(isTeacher: isTeacher);
                      final guidePanel = _GuidePanel(isTeacher: isTeacher);

                      if (stacked) {
                        return Column(
                          children: [
                            startPanel,
                            const SizedBox(height: 18),
                            guidePanel,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: startPanel),
                          const SizedBox(width: 18),
                          Expanded(flex: 2, child: guidePanel),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final bool isTeacher;

  const _DashboardHero({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14B8A6),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -42,
            child: Icon(
              isTeacher ? Icons.school_rounded : Icons.auto_stories_rounded,
              size: 170,
              color: Colors.white.withOpacity(0.12),
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
                child: Text(
                  isTeacher ? 'Teacher Workspace' : 'Student Workspace',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isTeacher ? 'Welcome to your teaching dashboard' : 'Welcome to your learning dashboard',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isTeacher
                    ? 'Start with your classes, review student performance, and prepare learning activities in one place.'
                    : 'Open your classes, continue activities, and track your learning progress in one place.',
                style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                    onPressed: () => context.go('/subjects'),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(isTeacher ? 'Open Classes' : 'Open My Classes'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.6)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                    onPressed: () => context.go(isTeacher ? '/analytics' : '/results'),
                    icon: const Icon(Icons.insights_rounded),
                    label: Text(isTeacher ? 'View Performance' : 'View Results'),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8)),
                ],
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
              const SizedBox(height: 16),
              Text(buttonLabel, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartPanel extends StatelessWidget {
  final bool isTeacher;

  const _StartPanel({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.school_rounded, color: Color(0xFF0284C7), size: 34),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isTeacher ? 'Start from your classes' : 'Continue from your classes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    isTeacher
                        ? 'Open a class to manage learning files, review cards, tests, scores, and student progress.'
                        : 'Open a class to access learning files, review cards, tests, and your results.',
                    style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => context.go('/subjects'),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open Classes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePanel extends StatelessWidget {
  final bool isTeacher;

  const _GuidePanel({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final steps = isTeacher
        ? const [
            _GuideStep(icon: Icons.menu_book_rounded, title: 'Open a class', text: 'Manage modules and activities.'),
            _GuideStep(icon: Icons.quiz_rounded, title: 'Prepare tests', text: 'Create assessments for students.'),
            _GuideStep(icon: Icons.insights_rounded, title: 'Check progress', text: 'Review scores and performance.'),
          ]
        : const [
            _GuideStep(icon: Icons.menu_book_rounded, title: 'Open a class', text: 'Start with your enrolled subjects.'),
            _GuideStep(icon: Icons.style_rounded, title: 'Review lessons', text: 'Use materials and cards.'),
            _GuideStep(icon: Icons.assessment_rounded, title: 'Check results', text: 'Monitor your submitted work.'),
          ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick guide', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            ...steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, child: Icon(step.icon, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(step.text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _GuideStep {
  final IconData icon;
  final String title;
  final String text;

  const _GuideStep({required this.icon, required this.title, required this.text});
}
