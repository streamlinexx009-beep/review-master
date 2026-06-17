import 'package:flutter/material.dart';

class PerformanceBadge extends StatelessWidget {
  final String category;

  const PerformanceBadge({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      ),
    );
  }
}