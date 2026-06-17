import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/batch_providers.dart';
import '../../subjects/providers/subject_provider.dart';

class BatchDetailsScreen extends ConsumerWidget {
final String batchId;

const BatchDetailsScreen({
super.key,
required this.batchId,
});

@override   
Widget build(BuildContext context, WidgetRef ref) {
final batchAsync = ref.watch(
batchProvider(batchId),
);

return Padding(
  padding: const EdgeInsets.all(24),
  child: batchAsync.when(
    loading: () => const Center(
      child: CircularProgressIndicator(),
    ),
    error: (error, stack) =>
        Center(
      child: Text(
        error.toString(),
      ),
    ),
    data: (batch) {
      final studentCountAsync =
          ref.watch(
        studentCountProvider(
          batchId,
        ),
      );



      final batchStudentsAsync =
          ref.watch(
        batchStudentsProvider(
          batchId,
        ),
      );

      final searchQuery =
          ref.watch(
        batchStudentSearchProvider,
      );
      final batchSubjectsAsync =
            ref.watch(
        batchSubjectsProvider(
            batchId,
        ),
        );  

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            batch.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            batch.description ??
                'No description',
          ),

          const SizedBox(
            height: 16,
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child:
                ElevatedButton.icon(
              icon: const Icon(
                Icons.person_add,
              ),
              label: const Text(
                'Add Student',
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder:
                      (context) {
                    return Consumer(
                      builder: (
                        context,
                        ref,
                        child,
                      ) {
                        final studentsAsync =
                            ref.watch(
                          studentsProvider,
                        );

                        final enrolledIdsAsync =
                            ref.watch(
                          enrolledStudentIdsProvider(
                            batchId,
                          ),
                        );

                        return AlertDialog(
                          title:
                              const Text(
                            'Select Student',
                          ),
                          content:
                              SizedBox(
                            width:
                                450,
                            height:
                                450,
                            child:
                                studentsAsync.when(
                              loading:
                                  () =>
                                      const Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                              error:
                                  (
                                error,
                                stack,
                              ) =>
                                      Text(
                                error
                                    .toString(),
                              ),
                              data:
                                  (
                                students,
                              ) {
                                return enrolledIdsAsync.when(
                                  loading:
                                      () =>
                                          const Center(
                                    child:
                                        CircularProgressIndicator(),
                                  ),
                                  error:
                                      (
                                    error,
                                    stack,
                                  ) =>
                                          Text(
                                    error
                                        .toString(),
                                  ),
                                  data:
                                      (
                                    enrolledIds,
                                  ) {
                                    final availableStudents =
                                        students
                                            .where(
                                              (
                                                student,
                                              ) =>
                                                  !enrolledIds.contains(
                                                student[
                                                    'id'],
                                              ),
                                            )
                                            .toList();

                                    if (availableStudents
                                        .isEmpty) {
                                      return const Center(
                                        child:
                                            Text(
                                          'All students are already enrolled',
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount:
                                          availableStudents.length,
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        final student =
                                            availableStudents[
                                                index];

                                        return ListTile(
                                          leading:
                                              const Icon(
                                            Icons.person,
                                          ),
                                          title:
                                              Text(
                                            student['full_name'] ??
                                                '',
                                          ),
                                          subtitle:
                                              Text(
                                            student['email'] ??
                                                '',
                                          ),
                                          onTap:
                                              () async {
                                            await ref
                                                .read(
                                                  batchRepositoryProvider,
                                                )
                                                .addStudentToBatch(
                                                  batchId:
                                                      batchId,
                                                  studentId:
                                                      student['id'],
                                                );

                                            ref.invalidate(
                                              studentCountProvider(
                                                batchId,
                                              ),
                                            );

                                            ref.invalidate(
                                              enrolledStudentIdsProvider(
                                                batchId,
                                              ),
                                            );

                                            ref.invalidate(
                                              batchStudentsProvider(
                                                batchId,
                                              ),
                                            );

                                            if (context
                                                .mounted) {
                                              Navigator.pop(
                                                context,
                                              );

                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text(
                                                    'Student added to batch',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          'Students',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        studentCountAsync.when(
                          loading:
                              () =>
                                  const Text(
                            '...',
                          ),
                          error:
                              (
                            error,
                            stack,
                          ) =>
                                  const Text(
                            '0',
                          ),
                          data:
                              (
                            count,
                          ) =>
                                  Text(
                            count.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      children:
                          const [
                        Icon(
                          Icons.menu_book,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Materials',
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          '0',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      children:
                          const [
                        Icon(
                          Icons.quiz,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Exams',
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          '0',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Subjects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text(
                'Assign Subject',
            ),
           onPressed: () {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (
          context,
          ref,
          child,
        ) {
          final subjectsAsync =
              ref.watch(
            subjectsProvider,
          );

          final assignedIdsAsync =
              ref.watch(
            assignedSubjectIdsProvider(
              batchId,
            ),
          );

          return AlertDialog(
            title: const Text(
              'Assign Subject',
            ),
            content: SizedBox(
              width: 500,
              height: 450,
              child: subjectsAsync.when(
                loading: () =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),
                error:
                    (
                  error,
                  stack,
                ) =>
                        Text(
                  error.toString(),
                ),
                data:
                    (
                  subjects,
                ) {
                  return assignedIdsAsync.when(
                    loading: () =>
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                    error:
                        (
                      error,
                      stack,
                    ) =>
                            Text(
                      error.toString(),
                    ),
                    data:
                        (
                      assignedIds,
                    ) {
                      final availableSubjects =
                          subjects
                              .where(
                                (
                                  subject,
                                ) =>
                                    !assignedIds.contains(
                                  subject.id,
                                ),
                              )
                              .toList();

                      if (availableSubjects
                          .isEmpty) {
                        return const Center(
                          child: Text(
                            'All subjects are already assigned',
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount:
                            availableSubjects.length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final subject =
                              availableSubjects[
                                  index];

                          return ListTile(
                            leading:
                                const Icon(
                              Icons.book,
                            ),
                            title: Text(
                              subject.name,
                            ),
                            subtitle:
                                Text(
                              subject.description ??
                                  '',
                            ),
                            onTap:
                                () async {
                              await ref
                                  .read(
                                    batchRepositoryProvider,
                                  )
                                  .assignSubjectToBatch(
                                    batchId:
                                        batchId,
                                    subjectId:
                                        subject.id,
                                  );

                              ref.invalidate(
                                batchSubjectsProvider(
                                  batchId,
                                ),
                              );

                              ref.invalidate(
                                assignedSubjectIdsProvider(
                                  batchId,
                                ),
                              );

                              if (context
                                  .mounted) {
                                Navigator.pop(
                                  context,
                                );

                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(
                                      '${subject.name} assigned',
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
},
            ),
            const SizedBox(height: 12),

          batchSubjectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (subjects) {
              if (subjects.isEmpty) {
                return const Text('No subjects assigned');
              }

              return Column(
                children: subjects.map((subject) {
                  final data = subject['subjects'] as Map<String, dynamic>;
                 return Card(
  child: ListTile(
    leading: const Icon(
      Icons.book,
    ),
    title: Text(
      data['name'],
    ),
    subtitle: Text(
      data['description'] ?? '',
    ),
    trailing: IconButton(
      icon: const Icon(
        Icons.delete,
      ),
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Remove Subject'),
              content: Text(
                'Remove ${data['name']} from this batch?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        );

        if (confirm != true) {
          return;
        }

        await ref
            .read(batchRepositoryProvider)
            .removeSubjectFromBatch(
              batchId: batchId,
              subjectId: subject['subject_id'],
            );

        ref.invalidate(batchSubjectsProvider(batchId));
        ref.invalidate(assignedSubjectIdsProvider(batchId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data['name']} removed'),
            ),
          );
        }
      },
    ),
  ),
);
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          TextField(
            decoration: const InputDecoration(
              hintText: 'Search students...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(batchStudentSearchProvider.notifier).state = value;
            },
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'Enrolled Students',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          batchStudentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (students) {
              final filtered = students.where((student) {
                final profile = student['profiles'] as Map<String, dynamic>;
                final name = (profile['full_name'] ?? '').toString().toLowerCase();
                final email = (profile['email'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery.toLowerCase()) ||
                    email.contains(searchQuery.toLowerCase());
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('No students found'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final student = filtered[index];
                  final profile = student['profiles'] as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(profile['full_name'] ?? ''),
                      subtitle: Text(profile['email'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await ref
                              .read(batchRepositoryProvider)
                              .removeStudentFromBatch(
                                batchId: batchId,
                                studentId: student['student_id'],
                              );

                          ref.invalidate(studentCountProvider(batchId));
                          ref.invalidate(enrolledStudentIdsProvider(batchId));
                          ref.invalidate(batchStudentsProvider(batchId));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

        ],
      );
    },
  ),
);
}
}
