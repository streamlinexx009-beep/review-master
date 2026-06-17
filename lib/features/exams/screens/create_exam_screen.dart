import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/models/subject_model.dart';
import '../../subjects/providers/subject_provider.dart';

import '../providers/exam_provider.dart';

class CreateExamScreen
    extends ConsumerStatefulWidget {
  const CreateExamScreen({
    super.key,
  });

  @override
  ConsumerState<CreateExamScreen>
      createState() =>
          _CreateExamScreenState();
}

class _CreateExamScreenState
    extends ConsumerState<CreateExamScreen> {
  String? selectedSubjectId;

  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final _passingScoreController =
      TextEditingController(
    text: '75',
  );

  final _timeLimitController =
      TextEditingController(
    text: '60',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passingScoreController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync =
        ref.watch(subjectsProvider);

    return Padding(
      padding:
          const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 700,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Exam',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(
                  height: 24,
                ),

                TextFormField(
                  controller:
                      _titleController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Exam Title',
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter exam title';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(
                  controller:
                      _descriptionController,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                subjectsAsync.when(
                  data: (subjects) {
                    return DropdownButtonFormField<
                        String>(
                      value:
                          selectedSubjectId,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Subject',
                        border:
                            OutlineInputBorder(),
                      ),
                      items:
                          subjects.map(
                        (
                          SubjectModel
                              subject,
                        ) {
                          return DropdownMenuItem<
                              String>(
                            value:
                                subject.id,
                            child: Text(
                              subject.name,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (
                        value,
                      ) {
                        setState(() {
                          selectedSubjectId =
                              value;
                        });
                      },
                      validator: (
                        value,
                      ) {
                        if (value ==
                            null) {
                          return 'Select a subject';
                        }
                        return null;
                      },
                    );
                  },
                  loading: () =>
                      const Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                  error: (
                    error,
                    stackTrace,
                  ) =>
                      Text(
                    error.toString(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(
                  controller:
                      _passingScoreController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Passing Score (%)',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(
                  controller:
                      _timeLimitController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Time Limit (minutes)',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        if (!_formKey
                            .currentState!
                            .validate()) {
                          return;
                        }

                        await ref
                            .read(
                              examRepositoryProvider,
                            )
                            .createExam(
                              title:
                                  _titleController
                                      .text
                                      .trim(),
                              description:
                                  _descriptionController
                                      .text
                                      .trim(),
                              subjectId:
                                  selectedSubjectId!,
                              passingScore:
                                  int.parse(
                                _passingScoreController
                                    .text,
                              ),
                              timeLimit:
                                  int.parse(
                                _timeLimitController
                                    .text,
                              ),
                            );

                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Exam created successfully',
                            ),
                          ),
                        );

                        _titleController
                            .clear();

                        _descriptionController
                            .clear();

                        _passingScoreController
                            .text = '75';

                        _timeLimitController
                            .text = '60';

                        setState(() {
                          selectedSubjectId =
                              null;
                        });
                      } catch (e) {
                        if (!mounted) {
                          return;
                        }

                        debugPrint(
                          'CREATE EXAM ERROR: $e',
                        );

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Create Exam',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}