import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exam_provider.dart';

class CreateQuestionScreen
    extends ConsumerStatefulWidget {
  final String examId;

  const CreateQuestionScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<CreateQuestionScreen>
      createState() =>
          _CreateQuestionScreenState();
}

class _CreateQuestionScreenState
    extends ConsumerState<CreateQuestionScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _questionController =
      TextEditingController();

  final _optionAController =
      TextEditingController();

  final _optionBController =
      TextEditingController();

  final _optionCController =
      TextEditingController();

  final _optionDController =
      TextEditingController();

  String? _correctAnswer;

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    try {
      await ref
          .read(
            examRepositoryProvider,
          )
          .createQuestion(
            examId:
                widget.examId,
            questionText:
                _questionController.text
                    .trim(),
            optionA:
                _optionAController.text
                    .trim(),
            optionB:
                _optionBController.text
                    .trim(),
            optionC:
                _optionCController.text
                    .trim(),
            optionD:
                _optionDController.text
                    .trim(),
            correctAnswer:
                _correctAnswer!,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Question saved successfully',
          ),
        ),
      );

      _questionController.clear();
      _optionAController.clear();
      _optionBController.clear();
      _optionCController.clear();
      _optionDController.clear();

      setState(() {
        _correctAnswer = null;
      });
    } catch (e) {
      if (!mounted) return;

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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 800,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Question',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  TextFormField(
                    controller:
                        _questionController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Question',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter question';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _optionAController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Option A',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter Option A';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _optionBController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Option B',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter Option B';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _optionCController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Option C',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter Option C';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _optionDController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Option D',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter Option D';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButtonFormField<
                      String>(
                    value:
                        _correctAnswer,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Correct Answer',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'A',
                        child: Text(
                          'Option A',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'B',
                        child: Text(
                          'Option B',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'C',
                        child: Text(
                          'Option C',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'D',
                        child: Text(
                          'Option D',
                        ),
                      ),
                    ],
                    onChanged: (
                      value,
                    ) {
                      setState(() {
                        _correctAnswer =
                            value;
                      });
                    },
                    validator:
                        (value) {
                      if (value ==
                          null) {
                        return 'Select correct answer';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed:
                          _saveQuestion,
                      child:
                          const Text(
                        'Save Question',
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