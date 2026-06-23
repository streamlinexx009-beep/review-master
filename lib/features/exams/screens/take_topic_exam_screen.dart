import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../analytics/services/topic_mastery_service.dart';
import '../services/topic_exam_service.dart';

class TakeTopicExamScreen extends StatefulWidget {
  final String examId;

  const TakeTopicExamScreen({
    super.key,
    required this.examId,
  });

  @override
  State<TakeTopicExamScreen> createState() => _TakeTopicExamScreenState();
}

class _TakeTopicExamScreenState extends State<TakeTopicExamScreen> {
  final _supabase = Supabase.instance.client;
  final Map<String, String> answers = {};

  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final result = await TopicExamService.getQuestions(widget.examId);

      if (!mounted) return;
      setState(() {
        questions = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _submitExam() async {
    if (_submitting || questions.isEmpty) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _submitting = true;
    });

    try {
      var correct = 0;

      for (final question in questions) {
        final selected = answers[question['id']];

        if (selected == question['correct_answer']) {
          correct++;
        }
      }

      final score = (correct / questions.length) * 100;
      final passed = score >= 75;

      final examData = await _supabase
          .from('topic_exams')
          .select('topic_id')
          .eq('id', widget.examId)
          .maybeSingle();

      final topicId = examData?['topic_id'] as String?;

      final answerPayload = questions.map((question) {
        final selected = answers[question['id']] ?? '';

        return {
          'question_id': question['id'],
          'selected_answer': selected,
        };
      }).toList();

      final savedSecurely = await TopicExamService.submitAttemptSecure(
        examId: widget.examId,
        answers: answerPayload,
      );

      if (!savedSecurely) {
        await _submitLegacyAttempt(
          userId: user.id,
          score: score,
          passed: passed,
        );
      }

      if (topicId != null) {
        await TopicMasteryService().updateExamMastery(
          studentId: user.id,
          topicId: topicId,
          score: score,
        );
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Exam Completed'),
          content: Text(
            'Score: ${score.toStringAsFixed(0)}%\n'
            'Result: ${passed ? "PASSED" : "FAILED"}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();

                if (topicId == null) {
                  context.go('/exams');
                } else {
                  context.go('/topics/$topicId');
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit topic exam: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _submitLegacyAttempt({
    required String userId,
    required double score,
    required bool passed,
  }) async {
    final attempt = await _supabase
        .from('topic_exam_attempts')
        .insert({
          'topic_exam_id': widget.examId,
          'student_id': userId,
          'score': score,
          'passed': passed,
        })
        .select('id')
        .single();

    final attemptId = attempt['id'];
    final answerRows = questions.map((question) {
      final selected = answers[question['id']] ?? '';

      return {
        'attempt_id': attemptId,
        'question_id': question['id'],
        'selected_answer': selected,
        'correct_answer': question['correct_answer'],
        'is_correct': selected == question['correct_answer'],
      };
    }).toList();

    if (answerRows.isNotEmpty) {
      await _supabase.from('topic_exam_attempt_answers').insert(answerRows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Topic Exam'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(child: Text('No questions found.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final question = questions[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${question['question']}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildOption(question, question['option_a'] as String?),
                                    _buildOption(question, question['option_b'] as String?),
                                    _buildOption(question, question['option_c'] as String?),
                                    _buildOption(question, question['option_d'] as String?),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: answers.length != questions.length || _submitting ? null : _submitExam,
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Submit Exam'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOption(Map<String, dynamic> question, String? option) {
    if (option == null || option.isEmpty) {
      return const SizedBox.shrink();
    }

    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: answers[question['id']],
      onChanged: _submitting
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                answers[question['id']] = value;
              });
            },
    );
  }
}
