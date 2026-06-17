import 'package:flutter/material.dart';

class FlashcardSetsScreen extends StatelessWidget {
  const FlashcardSetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Sets'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Algebra Flashcards'),
          ),
        ],
      ),
    );
  }
}