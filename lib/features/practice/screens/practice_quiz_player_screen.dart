import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/practice_question.dart';
import '../services/practice_service.dart';

class PracticeQuizPlayerScreen extends StatefulWidget {
  final String topicId;

  const PracticeQuizPlayerScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<PracticeQuizPlayerScreen> createState() => _PracticeQuizPlayerScreenState();
}

class _PracticeQuizPlayerScreenState extends State<PracticeQuizPlayerScreen> {
  final _service = PracticeService();

  bool _loading = true;
  bool _submitting = false;

  List<PracticeQuestion> _questions = [];
  int _currentIndex = 0;
  final Map<int, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _service.getPracticeQuestions(widget.topicId);

    if (!mounted) return;

    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  Future<void> _submitQuiz() async {
    if (_submitting) return;

    var score = 0;

    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctAnswer) {
        score++;
      }
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final answerPayload = <Map<String, dynamic>>[];

      for (var i = 0; i < _questions.length; i++) {
        answerPayload.add({
          'question_id': _questions[i].id,
          'selected_answer': _answers[i] ?? '',
        });
      }

      await _service.saveAttempt(
        userId: user.id,
        topicId: widget.topicId,
        score: score,
        totalQuestions: _questions.length,
        answers: answerPayload,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save practice attempt: $error')),
      );
      return;
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }

    if (!mounted) return;

    final percentage = _questions.isEmpty ? 0 : (score / _questions.length) * 100;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Complete'),
        content: Text(
          'Score: $score / ${_questions.length}\n\n'
          'Percentage: ${percentage.toStringAsFixed(1)}%',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              this.context.go('/topics/${widget.topicId}');
            },
            child: const Text('Back to Topic'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice Quiz')),
        body: const Center(child: Text('No practice questions found.')),
      );
    }

    final question = _questions[_currentIndex];

    final options = [
      question.optionA,
      question.optionB,
      if (question.optionC != null) question.optionC!,
      if (question.optionD != null) question.optionD!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...options.map(
              (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _answers[_currentIndex],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _answers[_currentIndex] = value;
                        });
                      },
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              setState(() {
                                _currentIndex--;
                              });
                            },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            if (_currentIndex < _questions.length - 1) {
                              setState(() {
                                _currentIndex++;
                              });
                            } else {
                              _submitQuiz();
                            }
                          },
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentIndex == _questions.length - 1 ? 'Submit Quiz' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
