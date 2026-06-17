import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/subject_model.dart';
import '../providers/subject_provider.dart';

class EditSubjectScreen
    extends ConsumerStatefulWidget {
  final SubjectModel subject;

  const EditSubjectScreen({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<EditSubjectScreen>
      createState() =>
          _EditSubjectScreenState();
}

class _EditSubjectScreenState
    extends ConsumerState<EditSubjectScreen> {

  late final TextEditingController
      nameController;

  late final TextEditingController
      descriptionController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text: widget.subject.name,
    );

    descriptionController =
        TextEditingController(
      text:
          widget.subject.description ??
          '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateSubject() async {
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

      final updatedSubject =
          widget.subject.copyWith(
        name: name,
        description:
            description.isEmpty
                ? null
                : description,
      );

      await ref
          .read(
            subjectRepositoryProvider,
          )
          .updateSubject(
            updatedSubject,
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
          'Edit Subject',
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
                              : updateSubject,
                      icon:
                          const Icon(
                        Icons.save,
                      ),
                      label:
                          isLoading
                              ? const Text(
                                  'Saving...',
                                )
                              : const Text(
                                  'Update Subject',
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