import 'package:flutter/material.dart';

class AnswerTile
    extends StatelessWidget {

  final String answer;

  final bool isCorrect;

  const AnswerTile({
    super.key,
    required this.answer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Text(answer),

      trailing: Icon(
        isCorrect
            ? Icons.check_circle
            : Icons.cancel,
      ),
    );
  }
}