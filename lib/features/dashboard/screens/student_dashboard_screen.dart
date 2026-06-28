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

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _DashboardHero(isTeacher: isTeacher),
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
      padding: const EdgeInsets.all(34),
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
            bottom: -48,
            child: Icon(
              isTeacher ? Icons.school_rounded : Icons.auto_stories_rounded,
              size: 190,
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
                  fontSize: 36,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 760,
                child: Text(
                  isTeacher
                      ? 'Use the sidebar to open your classes, student performance, study planner, and batches. Start with Classes when preparing materials, review cards, tests, and scores.'
                      : 'Use the sidebar to open your classes, activities, planner, and results. Start with your classes to continue learning.',
                  style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 16, height: 1.45),
                ),
              ),
              const SizedBox(height: 24),
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
                    label: Text(isTeacher ? 'View Student Performance' : 'View Results'),
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
