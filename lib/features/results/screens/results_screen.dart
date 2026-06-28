import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exams/models/exam_attempt_model.dart';
import '../providers/results_providers.dart';
import 'result_details_screen.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(myResultsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: results.when(
        data: (attempts) {
          if (attempts.isEmpty) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultsHeader(),
                SizedBox(height: 20),
                Expanded(child: _EmptyState()),
              ],
            );
          }

          final totalAttempts = attempts.length;
          final passedCount = attempts.where((a) => a.passed).length;
          final failedCount = totalAttempts - passedCount;
          final averageScore = attempts.map((a) => a.score).reduce((a, b) => a + b) / totalAttempts;
          final passRate = totalAttempts == 0 ? 0.0 : (passedCount / totalAttempts) * 100;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ResultsHeader(),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 900 ? 2 : 4;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: constraints.maxWidth < 900 ? 1.55 : 1.35,
                    children: [
                      _StatCard(title: 'Attempts', value: '$totalAttempts', helper: 'submitted exams', icon: Icons.assignment_turned_in_outlined, color: const Color(0xFF0EA5E9)),
                      _StatCard(title: 'Average', value: '${averageScore.toStringAsFixed(0)}%', helper: 'overall score', icon: Icons.trending_up_rounded, color: const Color(0xFF8B5CF6)),
                      _StatCard(title: 'Pass Rate', value: '${passRate.toStringAsFixed(0)}%', helper: '$passedCount passed', icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
                      _StatCard(title: 'Needs Review', value: '$failedCount', helper: 'failed attempts', icon: Icons.support_agent_rounded, color: const Color(0xFFF97316)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text('Exam Attempts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(99)),
                    child: Text('$totalAttempts records', style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: attempts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _AttemptCard(attempt: attempts[index]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString(), textAlign: TextAlign.center)),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFFDCFCE7), Colors.white]),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.assessment_rounded, color: Color(0xFF16A34A), size: 34)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Results Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 6),
              const Text('Review exam attempts, pass status, scores, and detailed answer feedback.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final ExamAttemptModel attempt;

  const _AttemptCard({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final statusColor = attempt.passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final scoreValue = (attempt.score.clamp(0, 100) / 100).toDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(18)), child: Icon(attempt.passed ? Icons.check_rounded : Icons.close_rounded, color: statusColor)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(attempt.examTitle ?? 'Exam Attempt', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)))),
                    _ResultBadge(passed: attempt.passed),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('Score: ${attempt.score.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(value: scoreValue, minHeight: 8, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(statusColor)),
                      ),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(width: 14),
              FilledButton.tonalIcon(onPressed: () => _openDetails(context), icon: const Icon(Icons.visibility_outlined, size: 18), label: const Text('Details')),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultDetailsScreen(
          attemptId: attempt.id,
          examTitle: attempt.examTitle ?? 'Exam Attempt',
          score: attempt.score,
          passed: attempt.passed,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.helper, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(0.20))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(helper, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      ]),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool passed;

  const _ResultBadge({required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(99)),
      child: Text(passed ? 'Passed' : 'Needs Review', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              const CircleAvatar(radius: 34, child: Icon(Icons.assessment_outlined)),
              const SizedBox(height: 18),
              Text('No results yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Exam attempts and performance summaries will appear here after a student submits an exam.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
            ]),
          ),
        ),
      ),
    );
  }
}
