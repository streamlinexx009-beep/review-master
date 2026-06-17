import 'package:flutter/material.dart';

class CreateStudyPlanScreen
    extends StatefulWidget {

  const CreateStudyPlanScreen({
    super.key,
  });

  @override
  State<CreateStudyPlanScreen>
      createState() =>
          _CreateStudyPlanScreenState();
}

class _CreateStudyPlanScreenState
    extends State<CreateStudyPlanScreen> {

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
          'Create Study Plan',
        ),
      ),
      body: Container(),
    );
  }
}