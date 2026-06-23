import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exam_question_model.dart';
import '../providers/exam_provider.dart';

class TakeExamScreen extends ConsumerStatefulWidget {
  final String examId;

  const TakeExamScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends ConsumerState<TakeExamScreen> {
  final Map<String, String> answers = {};

  int currentQuestionIndex = 0;
  bool _submitting = false;

  Future<void> _submitExam({
    required List<ExamQuestionModel> questions,
    required int passingScore,
  }) async {
    if (_submitting) return;

    var localCorrectAnswers = 0;
    final hasLocalAnswers = questions.every((question) => question.correctAnswer.isNotEmpty);

    if (hasLocalAnswers) {
      for (final question in questions) {
        if (answers[question.id] == question.correctAnswer) {
          localCorrectAnswers++;
        }
      }
    }

    final localPercentage = questions.isEmpty
        ? 0
        : ((localCorrectAnswers / questions.length) * 100).round();
    final localPassed = localPercentage >= passingScore;

    setState(() {
      _submitting = true;
    });

    try {
      final answerPayload = questions.map((question) {
        final selected = answers[question.id] ?? '';

        return {
          'question_id': question.id,
          'selected_answer': selected,
          'correct_answer': question.correctAnswer,
          'is_correct': hasLocalAnswers && selected == question.correctAnswer,
        };
      }).toList();

      final result = await ref.read(examRepositoryProvider).submitExam(
            examId: widget.examId,
            score: localPercentage.toDouble(),
            passed: localPassed,
            answers: answerPayload,
          );

      if (!mounted) return;

      final correctAnswers = (result['correct_answers'] as num?)?.toInt() ?? localCorrectAnswers;
      final totalQuestions = (result['total_questions'] as num?)?.toInt() ?? questions.length;
      final percentage = (result['score'] as num?)?.toDouble() ?? localPercentage.toDouble();
      final passed = result['passed'] as bool? ?? localPassed;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Exam Completed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: $correctAnswers / $totalQuestions'),
                const SizedBox(height: 8),
                Text('Percentage: ${percentage.toStringAsFixed(0)}%'),
                const SizedBox(height: 16),
                Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save result: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examProvider(widget.examId));
    final questionsAsync = ref.watch(examQuestionsProvider(widget.examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Take Exam')),
      body: examAsync.when(
        data: (exam) {
          if (exam == null) {
            return const Center(child: Text('Exam not found'));
          }

          return questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text('No questions found'));
              }

              final question = questions[currentQuestionIndex];

              return Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.title, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text('Passing Score: ${exam.passingScore}%'),
                          Text('Time Limit: ${exam.timeLimit} minutes'),
                          const SizedBox(height: 32),
                          Text(
                            'Question ${currentQuestionIndex + 1} of ${questions.length}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.questionText,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  _AnswerOption(question: question, value: 'A', label: question.optionA),
                                  _AnswerOption(question: question, value: 'B', label: question.optionB),
                                  _AnswerOption(question: question, value: 'C', label: question.optionC),
                                  _AnswerOption(question: question, value: 'D', label: question.optionD),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (currentQuestionIndex > 0)
                                FilledButton(
                                  onPressed: _submitting
                                      ? null
                                      : () {
                                          setState(() {
                                            currentQuestionIndex--;
                                          });
                                        },
                                  child: const Text('Previous'),
                                ),
                              const Spacer(),
                              if (currentQuestionIndex < questions.length - 1)
                                FilledButton(
                                  onPressed: _submitting
                                      ? null
                                      : () {
                                          setState(() {
                                            currentQuestionIndex++;
                                          });
                                        },
                                  child: const Text('Next'),
                                ),
                              if (currentQuestionIndex == questions.length - 1)
                                FilledButton(
                                  onPressed: _submitting
                                      ? null
                                      : () async {
                                          await _submitExam(
                                            questions: questions,
                                            passingScore: exam.passingScore,
                                          );
                                        },
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Submit Exam'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _AnswerOption({
    required ExamQuestionModel question,
    required String value,
    required String? label,
  }) {
    if (label == null || label.isEmpty) {
      return const SizedBox.shrink();
    }

    return RadioListTile<String>(
      value: value,
      groupValue: answers[question.id],
      title: Text(label),
      onChanged: _submitting
          ? null
          : (selected) {
              if (selected == null) return;
              setState(() {
                answers[question.id] = selected;
              });
            },
    );
  }
}
