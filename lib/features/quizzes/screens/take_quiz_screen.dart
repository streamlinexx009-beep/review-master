import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/question_model.dart';
import '../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TakeQuizScreen({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<TakeQuizScreen>
      createState() =>
          _TakeQuizScreenState();
}

class _TakeQuizScreenState
    extends ConsumerState<TakeQuizScreen> {
  final Map<String, String>
      answers = {};

  bool isLoading = true;

  List<QuestionModel>
      questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void>
      _loadQuestions() async {
    try {
      final repo = ref.read(
        quizRepositoryProvider,
      );

      final data =
          await repo.getQuestions(
        widget.topicId,
      );

      if (mounted) {
        setState(() {
          questions = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void>
      _submitQuiz() async {
    final user =
        Supabase
            .instance
            .client
            .auth
            .currentUser;

    if (user == null) {
      return;
    }

    final repo = ref.read(
      quizRepositoryProvider,
    );

    final result =
        await repo.submitQuiz(
      topicId:
          widget.topicId,
      studentId: user.id,
      answers: answers,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                QuizResultScreen(
          score:
              (result[
                      'percentage']
                  as num)
              .toDouble(),
          correct:
              result['score']
                  as int,
          total:
              result[
                  'totalQuestions'] as int,
        ),
      ),
    );
  }

  Widget _optionTile({
    required QuestionModel
        question,
    required String option,
  }) {
    return RadioListTile<String>(
      value: option,
      groupValue:
          answers[question.id],
      title: Text(option),
      onChanged: (value) {
        setState(() {
          answers[question.id] =
              value!;
        });
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Take Quiz',
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : questions.isEmpty
              ? const Center(
                  child: Text(
                    'No quiz questions found.',
                  ),
                )
              : Column(
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
                              questions[
                                  index];

                          return Card(
                            margin:
                                const EdgeInsets.all(
                              12,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${q.question}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        12,
                                  ),

                                  _optionTile(
                                    question:
                                        q,
                                    option:
                                        q.optionA,
                                  ),

                                  _optionTile(
                                    question:
                                        q,
                                    option:
                                        q.optionB,
                                  ),

                                  if (q.optionC !=
                                      null)
                                    _optionTile(
                                      question:
                                          q,
                                      option:
                                          q.optionC!,
                                    ),

                                  if (q.optionD !=
                                      null)
                                    _optionTile(
                                      question:
                                          q,
                                      option:
                                          q.optionD!,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child:
                          SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton(
                          onPressed:
                              _submitQuiz,
                          child:
                              const Text(
                            'Submit Quiz',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}