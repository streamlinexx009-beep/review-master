import 'package:flutter/material.dart';

class TaskTile
    extends StatelessWidget {

  final String title;

  final bool completed;

  final ValueChanged<bool?>
      onChanged;

  const TaskTile({
    super.key,
    required this.title,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return CheckboxListTile(
      title: Text(title),
      value: completed,
      onChanged:
          onChanged,
    );
  }
}