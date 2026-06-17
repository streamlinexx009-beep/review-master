import 'package:flutter/material.dart';

class ErrorStateWidget
    extends StatelessWidget {

  final String message;

  const ErrorStateWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Text(
        message,
      ),
    );
  }
}