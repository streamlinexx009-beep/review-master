import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/flashcard_repository.dart';
import '../data/flashcard_repository_impl.dart';
import '../models/flashcard_model.dart';

final flashcardRepositoryProvider =
    Provider<FlashcardRepository>(
  (ref) {
    return FlashcardRepositoryImpl(
      Supabase.instance.client,
    );
  },
);

final flashcardsProvider =
    FutureProvider<
        List<FlashcardModel>>(
  (ref) {
    return ref
        .read(
          flashcardRepositoryProvider,
        )
        .getFlashcards();
  },
);