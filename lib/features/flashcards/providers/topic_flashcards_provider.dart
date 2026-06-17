import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flashcard_provider.dart';
import '../models/flashcard_model.dart';

final topicFlashcardsProvider =
    FutureProvider.family<
        List<FlashcardModel>,
        String>(
  (
    ref,
    topicId,
  ) {
    return ref
        .read(
          flashcardRepositoryProvider,
        )
        .getFlashcards(
          topicId: topicId,
        );
  },
);