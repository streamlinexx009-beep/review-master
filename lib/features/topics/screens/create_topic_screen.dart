import 'package:flutter/material.dart';

class CreateTopicScreen
    extends StatefulWidget {
  const CreateTopicScreen({
    super.key,
  });

  @override
  State<CreateTopicScreen>
      createState() =>
          _CreateTopicScreenState();
}

class _CreateTopicScreenState
    extends State<CreateTopicScreen> {
  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Create Topic',
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
                    'Topic Name',
              ),
            ),
            TextField(
              controller:
                  descriptionController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
              ),
            ),
          ],
        ),
      ),
    );
  }
}