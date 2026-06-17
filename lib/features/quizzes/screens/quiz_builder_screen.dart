import 'package:flutter/material.dart';

class QuizBuilderScreen
    extends StatefulWidget {

  final String quizId;

  const QuizBuilderScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizBuilderScreen>
      createState() =>
          _QuizBuilderScreenState();
}

class _QuizBuilderScreenState
    extends State<QuizBuilderScreen> {

  String questionType =
      'multiple_choice';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Quiz Builder',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            DropdownButton<String>(
              value:
                  questionType,
              items: const [

                DropdownMenuItem(
                  value:
                      'multiple_choice',
                  child:
                      Text(
                    'Multiple Choice',
                  ),
                ),

                DropdownMenuItem(
                  value:
                      'true_false',
                  child:
                      Text(
                    'True / False',
                  ),
                ),

                DropdownMenuItem(
                  value:
                      'identification',
                  child:
                      Text(
                    'Identification',
                  ),
                ),
              ],
              onChanged:
                  (value) {
                setState(() {
                  questionType =
                      value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}