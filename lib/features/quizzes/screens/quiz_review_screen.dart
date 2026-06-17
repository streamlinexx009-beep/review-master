import 'package:flutter/material.dart';

class QuizReviewScreen
    extends StatelessWidget {

  const QuizReviewScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Quiz Review',
        ),
      ),

      body: ListView(
        children: const [

          ListTile(
            title:
                Text(
              'Question',
            ),

            subtitle:
                Text(
              'Correct Answer',
            ),
          ),
        ],
      ),
    );
  }
}