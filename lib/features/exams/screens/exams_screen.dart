import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/exam_model.dart';
import '../providers/exam_provider.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        onPressed: () => context.go('/create-exam'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExamHeader(onCreate: () => context.go('/create-exam')),
            const SizedBox(height: 20),
            Expanded(
              child: examsAsync.when(
                data: (exams) {
                  if (exams.isEmpty) {
                    return _EmptyState(onCreate: () => context.go('/create-exam'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Available Exams', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFFFEDD5), borderRadius: BorderRadius.circular(99)),
                            child: Text('${exams.length} exam${exams.length == 1 ? '' : 's'}', style: const TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 3;
                            if (constraints.maxWidth < 1180) crossAxisCount = 2;
                            if (constraints.maxWidth < 720) crossAxisCount = 1;

                            return GridView.builder(
                              itemCount: exams.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.16,
                              ),
                              itemBuilder: (context, index) => _ExamCard(exam: exams[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString(), textAlign: TextAlign.center)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamHeader extends StatelessWidget {
  final VoidCallback onCreate;

  const _ExamHeader({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFFFFEDD5), Colors.white]),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFFFFEDD5), borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.quiz_rounded, color: Color(0xFFF97316), size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exams', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                const Text('Create assessments, add questions, and let students take exams in one organized space.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Exam'),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go('/take-exam/${exam.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFFFEDD5), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.quiz_rounded, color: Color(0xFFF97316))),
                  const Spacer(),
                  _StatusChip(label: '${exam.passingScore}% pass'),
                ],
              ),
              const SizedBox(height: 16),
              Text(exam.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(exam.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text('${exam.timeLimit} minutes', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.go('/take-exam/${exam.id}'),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/create-question/${exam.id}'),
                      child: const Text('Questions'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.quiz_outlined)),
              const SizedBox(height: 18),
              Text('No exams yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Create your first exam, then add questions for students to answer.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_rounded), label: const Text('Create Exam')),
            ]),
          ),
        ),
      ),
    );
  }
}
