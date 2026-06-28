import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/profile_service.dart';
import '../providers/subject_provider.dart';
import '../widgets/subject_card.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return FutureBuilder<String?>(
      future: ProfileService.getUserRole(),
      builder: (context, snapshot) {
        final isStudent = snapshot.data == 'student';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => isStudent ? const _JoinClassDialog() : const _CreateClassDialog(),
              );
            },
            icon: Icon(isStudent ? Icons.login_rounded : Icons.add_rounded),
            label: Text(isStudent ? 'Join class' : 'Create class'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubjectsHero(isStudent: isStudent),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isStudent ? 'My Classes' : 'Subject Classes',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isStudent
                                ? 'Open a class to view materials, flashcards, exams, and results.'
                                : 'Create and manage classes, modules, learning activities, and results.',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => isStudent ? const _JoinClassDialog() : const _CreateClassDialog(),
                        );
                      },
                      icon: Icon(isStudent ? Icons.login_rounded : Icons.add_rounded),
                      label: Text(isStudent ? 'Join class' : 'Create class'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: subjects.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return _EmptySubjectState(isStudent: isStudent);
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          var count = 4;
                          if (constraints.maxWidth < 1280) count = 3;
                          if (constraints.maxWidth < 940) count = 2;
                          if (constraints.maxWidth < 650) count = 1;

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: count,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.92,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) => SubjectCard(subject: items[index]),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _ErrorCard(message: e.toString()),
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

class _SubjectsHero extends StatelessWidget {
  final bool isStudent;

  const _SubjectsHero({required this.isStudent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
        ),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.school_rounded, size: 38, color: Color(0xFF0F766E)),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStudent ? 'Your learning starts inside a class' : 'Manage learning through subjects',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isStudent
                      ? 'Join using your class code, then access all materials, exams, flashcards, and results in one place.'
                      : 'Keep materials, flashcards, exams, results, and progress organized inside each subject.',
                  style: const TextStyle(color: Color(0xFF334155), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySubjectState extends StatelessWidget {
  final bool isStudent;

  const _EmptySubjectState({required this.isStudent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFCCFBF1),
                  child: Icon(isStudent ? Icons.login_rounded : Icons.add_rounded, color: const Color(0xFF0F766E)),
                ),
                const SizedBox(height: 18),
                Text(
                  isStudent ? 'No joined classes yet' : 'No classes created yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  isStudent
                      ? 'Ask your teacher for the class code, then join to see your subject modules.'
                      : 'Create your first subject class to start organizing modules and students.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message),
        ),
      ),
    );
  }
}

class _JoinClassDialog extends ConsumerStatefulWidget {
  const _JoinClassDialog();

  @override
  ConsumerState<_JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends ConsumerState<_JoinClassDialog> {
  final codeController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> joinClass() async {
    if (codeController.text.trim().isEmpty) return;
    setState(() => loading = true);

    try {
      final subject = await ref.read(subjectRepositoryProvider).joinSubjectByCode(codeController.text.trim());
      ref.invalidate(subjectsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined ${subject.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Join class'),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the subject code shared by your teacher.'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Class code',
                hintText: 'Example: ABCD1234',
                prefixIcon: const Icon(Icons.vpn_key_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onSubmitted: (_) => loading ? null : joinClass(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: loading ? null : joinClass, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Join')),
      ],
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Create class'),
      content: SizedBox(
        width: 540,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Class name', prefixIcon: const Icon(Icons.school_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 14),
            TextField(controller: sectionController, decoration: InputDecoration(labelText: 'Section', prefixIcon: const Icon(Icons.groups_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 14),
            TextField(controller: topicController, decoration: InputDecoration(labelText: 'Subject', prefixIcon: const Icon(Icons.menu_book_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 14),
            TextField(controller: roomController, decoration: InputDecoration(labelText: 'Room', prefixIcon: const Icon(Icons.meeting_room_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: loading ? null : createClass, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create class')),
      ],
    );
  }
}
