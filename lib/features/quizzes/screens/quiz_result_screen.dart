import 'package:flutter/material.dart';

class QuizResultScreen
    extends StatelessWidget {

  final double score;

  final int correct;

  final int total;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          'Quiz Result',
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Text(
              'Score: ${score.toStringAsFixed(2)}%',
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              '$correct / $total Correct',
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              score >= 75
                  ? 'PASSED'
                  : 'FAILED',
            ),
          ],
        ),
      ),
    );
  }
}