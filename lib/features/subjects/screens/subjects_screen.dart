import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/profile_service.dart';
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
    final subjects = ref.watch(subjectsProvider);

    return FutureBuilder<String?>(
      future: ProfileService.getUserRole(),
      builder: (context, roleSnapshot) {
        final isStudent = roleSnapshot.data == 'student';

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => isStudent
                    ? const _JoinSubjectDialog()
                    : const _CreateSubjectDialog(),
              );
            },
            icon: Icon(isStudent ? Icons.login : Icons.add),
            label: Text(isStudent ? 'Join Subject' : 'Create Subject'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subjects',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isStudent
                      ? 'Join a subject using the code or link from your instructor.'
                      : 'Manage and review your subjects.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: subjects.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isStudent ? Icons.class_outlined : Icons.menu_book_outlined,
                                      size: 52,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isStudent ? 'No subjects yet' : 'No subjects yet',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isStudent
                                          ? 'Ask your instructor for the subject code, then tap Join Subject.'
                                          : 'Create your first subject to start adding topics and materials.',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => isStudent
                                              ? const _JoinSubjectDialog()
                                              : const _CreateSubjectDialog(),
                                        );
                                      },
                                      icon: Icon(isStudent ? Icons.login : Icons.add),
                                      label: Text(isStudent ? 'Join Subject' : 'Create Subject'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SubjectCard(subject: items[index]),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Text(e.toString()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JoinSubjectDialog extends ConsumerStatefulWidget {
  const _JoinSubjectDialog();

  @override
  ConsumerState<_JoinSubjectDialog> createState() => _JoinSubjectDialogState();
}

class _JoinSubjectDialogState extends ConsumerState<_JoinSubjectDialog> {
  final codeController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> joinSubject() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final subject = await ref.read(subjectRepositoryProvider).joinSubjectByCode(code);
      ref.invalidate(subjectsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined ${subject.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
      title: const Text('Join Subject'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the subject code given by your instructor.'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Subject code',
                hintText: 'Example: ABCD1234',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => loading ? null : joinSubject(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: loading ? null : joinSubject,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}

class _CreateSubjectDialog extends ConsumerStatefulWidget {
  const _CreateSubjectDialog();

  @override
  ConsumerState<_CreateSubjectDialog> createState() => _CreateSubjectDialogState();
}

class _CreateSubjectDialogState extends ConsumerState<_CreateSubjectDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> createSubject() async {
    if (nameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ref.read(subjectRepositoryProvider).createSubject(
            name: nameController.text.trim(),
            description: descriptionController.text.trim(),
          );

      ref.invalidate(subjectsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
      title: const Text('Create Subject'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: loading ? null : createSubject,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
