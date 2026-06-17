import 'package:flutter/material.dart';

import '../models/question_model.dart';

class QuestionCard
    extends StatelessWidget {

  final QuestionModel question;

  const QuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              question.questionText,
            ),

            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}