import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subject_provider.dart';

class CreateSubjectScreen
    extends ConsumerStatefulWidget {
  const CreateSubjectScreen({
    super.key,
  });

  @override
  ConsumerState<CreateSubjectScreen>
      createState() =>
          _CreateSubjectScreenState();
}

class _CreateSubjectScreenState
    extends ConsumerState<CreateSubjectScreen> {

  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> createSubject() async {
    final name =
        nameController.text.trim();

    final description =
        descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Subject name is required',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await ref
          .read(
            subjectRepositoryProvider,
          )
          .createSubject(
            name: name,
            description:
                description.isEmpty
                    ? null
                    : description,
          );

      ref.invalidate(
        subjectsProvider,
      );

      if (mounted) {
        context.go('/subjects');
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Subject',
        ),
      ),
      body: Center(
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 700,
          ),
          padding:
              const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                24,
              ),
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
                      prefixIcon: Icon(
                        Icons.menu_book,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        descriptionController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Description',
                      alignLabelWithHint:
                          true,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : createSubject,
                      icon:
                          const Icon(
                        Icons.save,
                      ),
                      label:
                          isLoading
                              ? const Text(
                                  'Creating...',
                                )
                              : const Text(
                                  'Create Subject',
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}