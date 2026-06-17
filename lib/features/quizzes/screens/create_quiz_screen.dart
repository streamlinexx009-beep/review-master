import 'package:flutter/material.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() =>
      _CreateQuizScreenState();
}

class _CreateQuizScreenState
    extends State<CreateQuizScreen> {

  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final passingScoreController =
      TextEditingController(text: '75');

  final timeLimitController =
      TextEditingController(text: '30');

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Quiz',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller:
                  titleController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Quiz Title',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  descriptionController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  passingScoreController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    'Passing Score',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  timeLimitController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    'Time Limit (Minutes)',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child:
                  const Text(
                'Create Quiz',
              ),
            ),
          ],
        ),
      ),
    );
  }
}