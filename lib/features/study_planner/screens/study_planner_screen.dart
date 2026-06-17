import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/study_planner_provider.dart';
import '../providers/study_tasks_provider.dart';
import 'study_plan_details_screen.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final plans = ref.watch(
      studyPlansProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
        ),
      ),
      body: plans.when(
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 72,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No study plans yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Generate one from Analytics.',
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  '${plans.length} Study Plans',
                  style:
                      Theme.of(context)
                          .textTheme
                          .headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount:
                      plans.length,
                  itemBuilder:
                      (context, index) {
                    final plan =
                        plans[index];

                    final tasksAsync =
                        ref.watch(
                      studyTasksProvider(
                        plan.id,
                      ),
                    );

                    return tasksAsync.when(
                      data: (tasks) {
                        final totalTasks =
                            tasks.length;

                        final completedTasks =
                            tasks
                                .where(
                                  (task) =>
                                      task.isCompleted,
                                )
                                .length;

                        final progress =
                            totalTasks == 0
                                ? 0.0
                                : completedTasks /
                                    totalTasks;

                        final progressPercent =
                            (progress *
                                    100)
                                .round();

                        return Card(
                          elevation: 2,
                          margin:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          StudyPlanDetailsScreen(
                                    plan:
                                        plan,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.all(
                                          10,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .blue
                                              .withOpacity(
                                            0.1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .school,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 12,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              plan
                                                  .title,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    18,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  4,
                                            ),

                                            Text(
                                              plan.description ??
                                                  '',
                                              style:
                                                  TextStyle(
                                                color: Colors
                                                    .grey
                                                    .shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons
                                            .arrow_forward_ios,
                                        size:
                                            18,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      const Text(
                                        'Progress',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      Text(
                                        '$progressPercent%',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      8,
                                    ),
                                    child:
                                        LinearProgressIndicator(
                                      value:
                                          progress,
                                      minHeight:
                                          8,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Text(
                                    '$completedTasks of $totalTasks tasks completed',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () =>
                          const Card(
                        child: Padding(
                          padding:
                              EdgeInsets.all(
                            24,
                          ),
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      error: (e, _) =>
                          Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Text(
                            e.toString(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
        error: (e, _) =>
            Center(
          child: Text(
            e.toString(),
          ),
        ),
      ),
    );
  }
}