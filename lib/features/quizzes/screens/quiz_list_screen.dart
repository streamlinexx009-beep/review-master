import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_provider.dart';

class QuizListScreen
    extends ConsumerWidget {

  const QuizListScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final quizzes =
        ref.watch(
      quizzesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Quizzes',
        ),
      ),
      body: quizzes.when(
        data: (items) {

          return ListView.builder(
            itemCount:
                items.length,
            itemBuilder:
                (_, index) {

              return ListTile(
                title:
                    Text(
                  items[index]
                      .title,
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
        error: (e, _) =>
            Center(
          child:
              Text(e.toString()),
        ),
      ),
    );
  }
}