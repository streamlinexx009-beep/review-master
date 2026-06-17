import 'package:flutter/material.dart';

class LevelBadge
    extends StatelessWidget {

  final int level;

  const LevelBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {

    return Chip(
      label:
          Text(
        'Level $level',
      ),
    );
  }
}