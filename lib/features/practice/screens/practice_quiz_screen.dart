import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/practice_service.dart';

class PracticeQuizScreen
    extends StatefulWidget {
  final String topicId;

  const PracticeQuizScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<PracticeQuizScreen>
      createState() =>
          _PracticeQuizScreenState();
}

class _PracticeQuizScreenState
    extends State<PracticeQuizScreen> {
  bool _loading = false;

  Future<void>
      _generateQuiz() async {
    setState(() {
      _loading = true;
    });

    try {
      final count =
          await PracticeService()
              .generatePracticeQuiz(
        widget.topicId,
      );

      if (!mounted) return;

      if (count == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'No quiz questions found.',
            ),
          ),
        );
      } else {
        context.go(
          '/topics/${widget.topicId}/practice/play',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Practice Quiz'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 80,
              ),

              const SizedBox(
                height: 24,
              ),

              const Text(
                'Practice Quiz Generator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'Generate a random practice quiz from the available topic questions.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 32,
              ),

              SizedBox(
                width: 300,
                child:
                    ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.play_arrow,
                        ),
                  label: Text(
                    _loading
                        ? 'Generating...'
                        : 'Generate Practice Quiz',
                  ),
                  onPressed:
                      _loading
                          ? null
                          : _generateQuiz,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}