import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subject_provider.dart';
import '../widgets/subject_card.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final subjects =
        ref.watch(subjectsProvider);

    return Scaffold(
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                const _CreateSubjectDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Subject',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Subjects',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Manage and review your enrolled subjects',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: subjects.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No subjects yet',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder:
                        (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: SubjectCard(
                          subject:
                              items[index],
                        ),
                      );
                    },
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
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateSubjectDialog
    extends ConsumerStatefulWidget {
  const _CreateSubjectDialog();

  @override
  ConsumerState<_CreateSubjectDialog>
      createState() =>
          _CreateSubjectDialogState();
}

class _CreateSubjectDialogState
    extends ConsumerState<
        _CreateSubjectDialog> {
  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  bool loading = false;

  Future<void> createSubject() async {
    if (nameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ref
          .read(
            subjectRepositoryProvider,
          )
          .createSubject(
            name:
                nameController.text.trim(),
            description:
                descriptionController.text
                    .trim(),
          );

      ref.invalidate(
        subjectsProvider,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Subject created',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create Subject',
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Subject Name',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  descriptionController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              loading
                  ? null
                  : createSubject,
          child:
              loading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Create',
                  ),
        ),
      ],
    );
  }
}