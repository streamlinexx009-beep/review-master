import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_plan_model.dart';
import '../models/study_task_model.dart';
import '../providers/study_planner_provider.dart';

class StudyPlanDetailsScreen extends ConsumerStatefulWidget {
  final StudyPlanModel plan;

  const StudyPlanDetailsScreen({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<StudyPlanDetailsScreen>
      createState() =>
          _StudyPlanDetailsScreenState();
}

class _StudyPlanDetailsScreenState
    extends ConsumerState<StudyPlanDetailsScreen> {
  late Future<List<StudyTaskModel>>
      _tasksFuture;

  @override
  void initState() {
    super.initState();

    _tasksFuture = ref
        .read(
          studyPlannerRepositoryProvider,
        )
        .getTasks(
          widget.plan.id,
        );
  }

  Future<void> _reloadTasks() async {
    setState(() {
      _tasksFuture = ref
          .read(
            studyPlannerRepositoryProvider,
          )
          .getTasks(
            widget.plan.id,
          );
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan.title,
        ),
      ),
      body: FutureBuilder<
          List<StudyTaskModel>>(
        future: _tasksFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final tasks =
              snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found.',
              ),
            );
          }

          final completed =
              tasks
                  .where(
                    (t) =>
                        t.isCompleted,
                  )
                  .length;

          final progress =
              completed /
              tasks.length;

          return Column(
            children: [
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      widget.plan.description,
                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    LinearProgressIndicator(
                      value:
                          progress,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child:
                    ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(
                    16,
                  ),
                  itemCount:
                      tasks.length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                    final task =
                        tasks[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom:
                            12,
                      ),
                      child:
                          CheckboxListTile(
                        value: task
                            .isCompleted,
                        title: Text(
                          task.title,
                        ),
                        subtitle:
                            Text(
                          task.description,
                        ),
                        controlAffinity:
                            ListTileControlAffinity
                                .leading,
                        onChanged:
                            (
                              value,
                            ) async {
                          await ref
                              .read(
                                studyPlannerRepositoryProvider,
                              )
                              .toggleTask(
                                task.id,
                                value ??
                                    false,
                              );

                          await _reloadTasks();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
