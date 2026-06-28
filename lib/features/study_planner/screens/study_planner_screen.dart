import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/study_planner_provider.dart';
import '../providers/study_tasks_provider.dart';
import 'study_plan_details_screen.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(studyPlansProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          child: plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: e.toString()),
            data: (plans) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlannerHeader(
                    count: plans.length,
                    onCreate: () => _showCreatePlannerDialog(context, ref),
                  ),
                  const SizedBox(height: 22),
                  _PlannerGuide(onCreate: () => _showCreatePlannerDialog(context, ref)),
                  const SizedBox(height: 22),
                  Expanded(
                    child: plans.isEmpty
                        ? _EmptyPlanner(onCreate: () => _showCreatePlannerDialog(context, ref))
                        : ListView.separated(
                            itemCount: plans.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              final tasksAsync = ref.watch(studyTasksProvider(plan.id));

                              return tasksAsync.when(
                                loading: () => const _PlannerLoadingCard(),
                                error: (e, _) => _PlannerErrorCard(message: e.toString()),
                                data: (tasks) {
                                  final totalTasks = tasks.length;
                                  final completedTasks = tasks.where((task) => task.isCompleted).length;
                                  final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
                                  final progressPercent = (progress * 100).round();

                                  return _StudyPlanCard(
                                    title: plan.title,
                                    description: plan.description ?? 'No description added yet',
                                    completedTasks: completedTasks,
                                    totalTasks: totalTasks,
                                    progress: progress,
                                    progressPercent: progressPercent,
                                    onOpen: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => StudyPlanDetailsScreen(plan: plan)),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreatePlannerDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _CreatePlannerDialog(ref: ref),
    );
  }
}

class _PlannerHeader extends StatelessWidget {
  final int count;
  final VoidCallback onCreate;

  const _PlannerHeader({required this.count, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFFFFFFF)]),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.event_note_rounded, color: Color(0xFF0284C7), size: 34),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Study Planner', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                const Text('Create a clear study plan with tasks, deadlines, and progress tracking.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                const SizedBox(height: 12),
                _CountPill(count: count),
              ],
            ),
          ),
          const SizedBox(width: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }
}

class _PlannerGuide extends StatelessWidget {
  final VoidCallback onCreate;

  const _PlannerGuide({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const CircleAvatar(radius: 26, child: Icon(Icons.lightbulb_outline_rounded)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What should a study plan contain?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('Example: Review lesson summary, answer practice questions, revisit flashcards, then take a short quiz.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_task_rounded), label: const Text('Plan Now')),
          ],
        ),
      ),
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  final String title;
  final String description;
  final int completedTasks;
  final int totalTasks;
  final double progress;
  final int progressPercent;
  final VoidCallback onOpen;

  const _StudyPlanCard({
    required this.title,
    required this.description,
    required this.completedTasks,
    required this.totalTasks,
    required this.progress,
    required this.progressPercent,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.event_note_rounded, color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                        const SizedBox(height: 5),
                        Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.tonalIcon(onPressed: onOpen, icon: const Icon(Icons.open_in_new_rounded, size: 18), label: const Text('Open')),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text('Progress', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Text('$progressPercent%', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: const Color(0xFFE2E8F0)),
              ),
              const SizedBox(height: 8),
              Text('$completedTasks of $totalTasks tasks completed', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatePlannerDialog extends StatefulWidget {
  final WidgetRef ref;

  const _CreatePlannerDialog({required this.ref});

  @override
  State<_CreatePlannerDialog> createState() => _CreatePlannerDialogState();
}

class _CreatePlannerDialogState extends State<_CreatePlannerDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? targetDate;
  bool saving = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a plan title.')));
      return;
    }

    setState(() => saving = true);

    try {
      await widget.ref.read(studyPlannerRepositoryProvider).createStudyPlan(
            title: title,
            description: description.isEmpty ? 'Personal study plan.' : description,
            targetDate: targetDate,
          );
      widget.ref.invalidate(studyPlansProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Study plan created. Open it to add tasks.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Study Plan'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Plan title', hintText: 'Example: Review for Midterm Exam', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'What should the student focus on?', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(targetDate == null ? 'Optional target date' : 'Target: ${targetDate!.month}/${targetDate!.day}/${targetDate!.year}'),
              trailing: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: targetDate ?? DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) setState(() => targetDate = picked);
                },
                child: const Text('Pick Date'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: saving ? null : _save,
          icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
          label: Text(saving ? 'Creating...' : 'Create Plan'),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(99)),
      child: Text('$count plan${count == 1 ? '' : 's'}', style: const TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _EmptyPlanner extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyPlanner({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 34, child: Icon(Icons.event_note_rounded)),
                const SizedBox(height: 18),
                Text('No study plans yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Create a plan for upcoming exams, weak topics, assignments, or daily review.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_rounded), label: const Text('Create Plan')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannerLoadingCard extends StatelessWidget {
  const _PlannerLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
  }
}

class _PlannerErrorCard extends StatelessWidget {
  final String message;

  const _PlannerErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(message)));
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, textAlign: TextAlign.center));
  }
}
