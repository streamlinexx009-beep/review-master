import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subject_provider.dart';
import '../widgets/subject_card.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const _CreateClassDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD7E5FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Text('Create classes for your students'),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: subjects.when(
                data: (items) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 22,
                    mainAxisSpacing: 22,
                    childAspectRatio: 1.03,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => SubjectCard(subject: items[index]),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateClassDialog extends ConsumerStatefulWidget {
  const _CreateClassDialog();

  @override
  ConsumerState<_CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends ConsumerState<_CreateClassDialog> {
  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final topicController = TextEditingController();
  final roomController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    topicController.dispose();
    roomController.dispose();
    super.dispose();
  }

  Future<void> createClass() async {
    if (nameController.text.trim().isEmpty) return;

    setState(() => loading = true);

    final description = [
      sectionController.text.trim(),
      topicController.text.trim(),
      roomController.text.trim(),
    ].where((value) => value.isNotEmpty).join(' / ');

    try {
      await ref.read(subjectRepositoryProvider).createSubject(
            name: nameController.text.trim(),
            description: description.isEmpty ? null : description,
          );
      ref.invalidate(subjectsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Create class'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Class name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
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
          onPressed: loading ? null : createClass,
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}
