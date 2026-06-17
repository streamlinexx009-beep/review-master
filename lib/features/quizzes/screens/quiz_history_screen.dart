import 'package:flutter/material.dart';

class QuizHistoryScreen
    extends StatelessWidget {

  const QuizHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          'Quiz History',
        ),
      ),

      body: ListView(
        children: const [

          ListTile(
            title:
                Text(
              'Algebra Quiz',
            ),
            subtitle:
                Text(
              '92%',
            ),
          ),
        ],
      ),
    );
  }
}