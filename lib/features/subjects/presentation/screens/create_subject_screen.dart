import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/subject_provider.dart';

class CreateSubjectScreen extends ConsumerStatefulWidget {
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
    if (nameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
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
                descriptionController.text.trim(),
          );

      ref.invalidate(
        subjectsProvider,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : createSubject,
                      child:
                          isLoading
                              ? const CircularProgressIndicator()
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