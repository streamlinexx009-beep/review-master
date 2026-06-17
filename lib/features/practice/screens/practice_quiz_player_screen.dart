import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/practice_question.dart';
import '../services/practice_service.dart';
import 'package:go_router/go_router.dart';

class PracticeQuizPlayerScreen
    extends StatefulWidget {
  final String topicId;

  const PracticeQuizPlayerScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<PracticeQuizPlayerScreen>
      createState() =>
          _PracticeQuizPlayerScreenState();
}

class _PracticeQuizPlayerScreenState
    extends State<PracticeQuizPlayerScreen> {
  final _service = PracticeService();

  bool _loading = true;

  List<PracticeQuestion> _questions =
      [];

  int _currentIndex = 0;

  final Map<int, String> _answers =
      {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void>
      _loadQuestions() async {
    final questions =
        await _service
            .getPracticeQuestions(
      widget.topicId,
    );

    if (!mounted) return;

    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  Future<void> _submitQuiz() async {
    int score = 0;

    for (int i = 0;
        i < _questions.length;
        i++) {
      if (_answers[i] ==
          _questions[i]
              .correctAnswer) {
        score++;
      }
    }

    final user =
        Supabase.instance.client.auth
            .currentUser;

    if (user != null) {
      await _service.saveAttempt(
        userId: user.id,
        topicId: widget.topicId,
        score: score,
        totalQuestions:
            _questions.length,
      );
    }

    if (!mounted) return;

    final percentage =
        _questions.isEmpty
            ? 0
            : (score /
                    _questions.length) *
                100;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text(
          'Practice Complete',
        ),
        content: Text(
          'Score: $score / ${_questions.length}\n\n'
          'Percentage: ${percentage.toStringAsFixed(1)}%',
        ),
       actions: [
  TextButton(
    onPressed: () {
      Navigator.of(
        context,
      ).pop();

      this.context.go(
        '/topics/${widget.topicId}',
      );
    },
    child: const Text(
      'Back to Topic',
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
    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Practice Quiz',
          ),
        ),
        body: const Center(
          child: Text(
            'No practice questions found.',
          ),
        ),
      );
    }

    final question =
        _questions[_currentIndex];

    final options = [
      question.optionA,
      question.optionB,
      if (question.optionC != null)
        question.optionC!,
      if (question.optionD != null)
        question.optionD!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1}/${_questions.length}',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ...options.map(
              (option) =>
                  RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue:
                    _answers[
                        _currentIndex],
                onChanged:
                    (value) {
                  setState(() {
                    _answers[
                            _currentIndex] =
                        value!;
                  });
                },
              ),
            ),

            const Spacer(),

            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      child:
                          const Text(
                        'Previous',
                      ),
                    ),
                  ),

                if (_currentIndex > 0)
                  const SizedBox(
                    width: 12,
                  ),

                Expanded(
                  child:
                      ElevatedButton(
                    onPressed: () {
                      if (_currentIndex <
                          _questions
                                  .length -
                              1) {
                        setState(() {
                          _currentIndex++;
                        });
                      } else {
                        _submitQuiz();
                      }
                    },
                    child: Text(
                      _currentIndex ==
                              _questions
                                      .length -
                                  1
                          ? 'Submit Quiz'
                          : 'Next',
                    ),
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