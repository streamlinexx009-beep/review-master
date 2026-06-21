import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/study_plan_model.dart';
import '../services/study_plan_service.dart';

class StudyPlanDetailsScreen extends StatefulWidget {
  final StudyPlanModel plan;

  const StudyPlanDetailsScreen({
    super.key,
    required this.plan,
  });

  @override
  State<StudyPlanDetailsScreen> createState() => _StudyPlanDetailsScreenState();
}

class _StudyPlanDetailsScreenState extends State<StudyPlanDetailsScreen> {
  final _service = StudyPlanService();
  bool _loading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _service.getTasks(widget.plan.id);

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    await _service.updateTaskStatus(
      task['id'],
      !(task['is_completed'] as bool),
    );

    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plan.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: widget.plan.progress / 100,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.plan.completedTasks}/${widget.plan.totalTasks} tasks completed',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _tasks.isEmpty
                        ? const Center(child: Text('No tasks found.'))
                        : ListView.separated(
                            itemCount: _tasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              final isCompleted = task['is_completed'] as bool? ?? false;

                              return Card(
                                child: CheckboxListTile(
                                  value: isCompleted,
                                  onChanged: (_) => _toggleTask(task),
                                  title: Text(task['title']?.toString() ?? ''),
                                  subtitle: Text(task['description']?.toString() ?? ''),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
