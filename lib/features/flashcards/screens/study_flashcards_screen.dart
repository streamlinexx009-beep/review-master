import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../analytics/services/topic_mastery_service.dart';
import '../models/flashcard_model.dart';
import '../widgets/flashcard_widget.dart';

class StudyFlashcardsScreen extends StatefulWidget {
  final List<FlashcardModel> flashcards;

  const StudyFlashcardsScreen({
    super.key,
    required this.flashcards,
  });

  @override
  State<StudyFlashcardsScreen> createState() =>
      _StudyFlashcardsScreenState();
}

class _StudyFlashcardsScreenState
    extends State<StudyFlashcardsScreen> {
  final _supabase =
      Supabase.instance.client;

  final _topicMasteryService =
      TopicMasteryService();

  int currentIndex = 0;
  bool showBack = false;
  bool saving = false;
  int knownCount = 0;
  int needPracticeCount = 0;

  FlashcardModel get currentCard =>
      widget.flashcards[currentIndex];

  Future<void> _recordReview(
    bool known,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) return;

    try {
      await _supabase
          .from('flashcard_reviews')
          .upsert({
        'student_id': user.id,
        'flashcard_id':
            currentCard.id,
        'known': known,
        'reviewed_at':
            DateTime.now()
                .toIso8601String(),
      }, onConflict: 'student_id,flashcard_id');
    } catch (e) {
      debugPrint(
        'Review save error: $e',
      );
    }
  }

  Future<void> _completeSession() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) return;

    final topicId =
        widget.flashcards.first.topicId;

if (topicId != null) {
  try {
    final flashcardScore =
        (knownCount /
                widget.flashcards.length) *
            100;

    await _topicMasteryService
        .updateFlashcardMastery(
      studentId: user.id,
      topicId: topicId,
      score: flashcardScore,
    );

    debugPrint(
      'Flashcard mastery updated: $flashcardScore%',
    );
  } catch (e) {
    debugPrint(
      'Mastery update error: $e',
    );
  }
}
  }

  Future<void> _nextCard(
  bool known,
) async {
  if (saving) return;

  setState(() {
    saving = true;
  });

  if (known) {
    knownCount++;
  } else {
    needPracticeCount++;
  }

  await _recordReview(
    known,
  );

  if (!mounted) return;

  if (currentIndex ==
      widget.flashcards.length - 1) {
    await _completeSession();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Study session completed!',
        ),
      ),
    );

    Navigator.of(context).pop();
    return;
  }

  setState(() {
    currentIndex++;
    showBack = false;
    saving = false;
  });
}
  @override
  Widget build(
    BuildContext context,
  ) {
    final card =
        currentCard;

    final progress =
        (currentIndex + 1) /
            widget.flashcards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card ${currentIndex + 1}/${widget.flashcards.length}',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
            ),

            const SizedBox(
              height: 24,
            ),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showBack =
                        !showBack;
                  });
                },
                child:
                    FlashcardWidget(
                  text: showBack
                      ? card.backText
                      : card.frontText,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            if (!showBack)
              SizedBox(
                width:
                    double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      showBack =
                          true;
                    });
                  },
                  child: const Text(
                    'Reveal Answer',
                  ),
                ),
              ),

            if (showBack)
              Row(
                children: [
                  Expanded(
                    child:
                        FilledButton
                            .tonal(
                      onPressed:
                          saving
                              ? null
                              : () =>
                                    _nextCard(
                        false,
                      ),
                      child:
                          const Text(
                        'Need Practice',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child:
                        FilledButton(
                      onPressed:
                          saving
                              ? null
                              : () =>
                                    _nextCard(
                        true,
                      ),
                      child:
                          const Text(
                        'I Knew This',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
