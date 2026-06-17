import 'package:flutter/material.dart';

class UnreadBadge
    extends StatelessWidget {

  final int count;

  const UnreadBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {

    return CircleAvatar(
      radius: 12,
      child: Text(
        count.toString(),
      ),
    );
  }
}