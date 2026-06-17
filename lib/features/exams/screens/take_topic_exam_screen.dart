import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/topic_exam_service.dart';
import 'package:go_router/go_router.dart';
import '../../analytics/services/topic_mastery_service.dart';

class TakeTopicExamScreen extends StatefulWidget {
  final String examId;

  const TakeTopicExamScreen({
    super.key,
    required this.examId,
  });

  @override
  State<TakeTopicExamScreen> createState() =>
      _TakeTopicExamScreenState();
}

class _TakeTopicExamScreenState
    extends State<TakeTopicExamScreen> {
  final _supabase =
      Supabase.instance.client;

  bool _loading = true;

  List<Map<String, dynamic>> questions = [];

  final Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final result =
          await TopicExamService.getQuestions(
        widget.examId,
      );

      setState(() {
        questions = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _submitExam() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) return;

    int correct = 0;

    for (final question in questions) {
      final selected =
          answers[question['id']];

      if (selected ==
          question['correct_answer']) {
        correct++;
      }
    }

    final score =
        ((correct / questions.length) * 100);

    final passed = score >= 75;

    final attempt =
        await _supabase
            .from('topic_exam_attempts')
            .insert({
              'topic_exam_id':
                  widget.examId,
              'student_id': user.id,
              'score': score,
              'passed': passed,
            })
            .select()
            .single();

    final attemptId =
        attempt['id'];

    for (final question in questions) {
      final selected =
          answers[question['id']] ?? '';

      await _supabase
          .from(
            'topic_exam_attempt_answers',
          )
          .insert({
            'attempt_id': attemptId,
            'question_id':
                question['id'],
            'selected_answer':
                selected,
            'correct_answer':
                question[
                    'correct_answer'],
            'is_correct':
                selected ==
                    question[
                        'correct_answer'],
          });
    }

final examData =
    await _supabase
        .from('topic_exams')
        .select('topic_id')
        .eq('id', widget.examId)
        .single();

final topicId =
    examData['topic_id'] as String;

    await TopicMasteryService().updateExamMastery(
  studentId: user.id,
  topicId: topicId,
  score: score,
);

if (!mounted) return;

showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => AlertDialog(
    title: const Text(
      'Exam Completed',
    ),
    content: Text(
      'Score: ${score.toStringAsFixed(0)}%\n'
      'Result: ${passed ? "PASSED" : "FAILED"}',
    ),
    actions: [
      TextButton(
  onPressed: () {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();

    context.go(
      '/topics/$topicId',
    );
  },
  child: const Text(
    'OK',
  ),
),
    ],
  ),
);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Take Topic Exam',
        ),
      ),
      body:
          _loading
              ? const Center(
                child:
                    CircularProgressIndicator(),
              )
              : questions.isEmpty
              ? const Center(
                child: Text(
                  'No questions found.',
                ),
              )
              : Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            questions.length,
                        itemBuilder:
                            (
                              context,
                              index,
                            ) {
                              final q =
                                  questions[index];

                              return Card(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        '${index + 1}. ${q['question']}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),

                                      const SizedBox(
                                        height:
                                            12,
                                      ),

                                      _buildOption(
                                        q,
                                        q['option_a'],
                                      ),

                                      _buildOption(
                                        q,
                                        q['option_b'],
                                      ),

                                      if (q['option_c'] !=
                                          null)
                                        _buildOption(
                                          q,
                                          q['option_c'],
                                        ),

                                      if (q['option_d'] !=
                                          null)
                                        _buildOption(
                                          q,
                                          q['option_d'],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                      ),
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton(
                        onPressed:
                            answers.length !=
                                    questions
                                        .length
                                ? null
                                : _submitExam,
                        child:
                            const Text(
                          'Submit Exam',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildOption(
    Map<String, dynamic> question,
    String option,
  ) {
    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue:
          answers[question['id']],
      onChanged: (value) {
        setState(() {
          answers[question['id']] =
              value!;
        });
      },
    );
  }
}