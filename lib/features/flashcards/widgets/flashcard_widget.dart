import 'package:flutter/material.dart';

class FlashcardWidget
    extends StatelessWidget {

  final String text;

  const FlashcardWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 5,
      child: SizedBox(
        height: 250,
        width: 400,
        child: Center(
          child: Text(
            text,
            textAlign:
                TextAlign.center,
          ),
        ),
      ),
    );
  }
}