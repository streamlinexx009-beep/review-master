import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/results_providers.dart';
import '../../exams/models/exam_attempt_answer_model.dart';

class ResultDetailsScreen extends ConsumerStatefulWidget {
final String attemptId;
final String examTitle;
final double score;
final bool passed;

const ResultDetailsScreen({
super.key,
required this.attemptId,
required this.examTitle,
required this.score,
required this.passed,
});

@override
ConsumerState<ResultDetailsScreen> createState() =>
_ResultDetailsScreenState();
}

class _ResultDetailsScreenState
extends ConsumerState<ResultDetailsScreen> {
Widget buildOption(
String letter,
String text,
ExamAttemptAnswerModel answer,
) {
final isSelected =
answer.selectedAnswer == letter;


final isCorrect =
    answer.correctAnswer == letter;

Color? color;

if (isCorrect) {
  color = Colors.green.shade100;
} else if (isSelected &&
    !answer.isCorrect) {
  color = Colors.red.shade100;
}

return Container(
  width: double.infinity,
  margin: const EdgeInsets.only(
    bottom: 6,
  ),
  padding:
      const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: color,
    borderRadius:
        BorderRadius.circular(8),
  ),
  child: Text(
    '$letter. $text',
  ),
);

}

@override
Widget build(BuildContext context) {
final answersAsync = ref.watch(
attemptAnswersProvider(
widget.attemptId,
),
);

return Scaffold(
  appBar: AppBar(
    title: const Text(
      'Result Details',
    ),
  ),
  body: SingleChildScrollView(
    padding:
        const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  widget.examTitle,
                  style: Theme.of(
                          context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Score: ${widget.score.toStringAsFixed(2)}%',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Chip(
                  backgroundColor:
                      widget.passed
                          ? Colors.green
                              .shade100
                          : Colors.red
                              .shade100,
                  label: Text(
                    widget.passed
                        ? 'PASSED'
                        : 'FAILED',
                    style:
                        TextStyle(
                      color:
                          widget.passed
                              ? Colors
                                  .green
                                  .shade900
                              : Colors
                                  .red
                                  .shade900,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        Card(
          child: Padding(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child: answersAsync.when(
              data: (answers) {
                if (answers
                    .isEmpty) {
                  return const Text(
                    'No answer records found.',
                  );
                }

                final totalQuestions =
                    answers.length;

                final correctAnswers =
                    answers
                        .where(
                          (a) =>
                              a.isCorrect,
                        )
                        .length;

                final incorrectAnswers =
                    totalQuestions -
                        correctAnswers;

                final accuracy =
                    (correctAnswers /
                            totalQuestions) *
                        100;

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Question Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Card(
                      color: Colors
                          .blue
                          .shade50,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Questions',
                                ),
                                Text(
                                  '$totalQuestions',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Correct',
                                ),
                                Text(
                                  '$correctAnswers',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors
                                            .green,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Incorrect',
                                ),
                                Text(
                                  '$incorrectAnswers',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors
                                            .red,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Accuracy',
                                ),
                                Text(
                                  '${accuracy.toStringAsFixed(1)}%',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors
                                            .blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ...answers
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        final index =
                            entry.key;
                        final answer =
                            entry.value;

                        return ExpansionTile(
                          title: Text(
                            'Question ${index + 1}',
                          ),
                          subtitle: Text(
                            answer
                                    .isCorrect
                                ? 'Correct'
                                : 'Incorrect',
                            style:
                                TextStyle(
                              color: answer
                                      .isCorrect
                                  ? Colors
                                      .green
                                  : Colors
                                      .red,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    answer
                                        .questionText,
                                  ),

                                  const SizedBox(
                                    height:
                                        12,
                                  ),

                                  buildOption(
                                    'A',
                                    answer
                                        .optionA,
                                    answer,
                                  ),

                                  buildOption(
                                    'B',
                                    answer
                                        .optionB,
                                    answer,
                                  ),

                                  buildOption(
                                    'C',
                                    answer
                                        .optionC,
                                    answer,
                                  ),

                                  buildOption(
                                    'D',
                                    answer
                                        .optionD,
                                    answer,
                                  ),

                                  const SizedBox(
                                    height:
                                        12,
                                  ),

                                  Text(
                                    'Your Answer: ${answer.selectedAnswer}',
                                  ),

                                  Text(
                                    'Correct Answer: ${answer.correctAnswer}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
              loading:
                  () =>
                      const Center(
                child:
                    CircularProgressIndicator(),
              ),
              error:
                  (
                    error,
                    stack,
                  ) =>
                      Text(
                error.toString(),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);


}
}
