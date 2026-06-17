import 'package:flutter/material.dart';

import '../services/practice_service.dart';

class PracticeHistoryScreen extends StatefulWidget {
  final String topicId;

  const PracticeHistoryScreen({
    super.key,
    required this.topicId,
  });

  @override
  State<PracticeHistoryScreen> createState() =>
      _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState
    extends State<PracticeHistoryScreen> {
  final _service = PracticeService();

  bool _loading = true;

  List<Map<String, dynamic>> _attempts = [];

  double _averageScore = 0;

  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final attempts =
          await _service.getPracticeAttempts(
        widget.topicId,
      );

      int best = 0;

      double totalPercentage = 0;

      for (final attempt in attempts) {
        final score =
            attempt['score'] as num;

        final totalQuestions =
            attempt['total_questions']
                as int;

        if (score > best) {
          best = score.toInt();
        }

        totalPercentage +=
            (score / totalQuestions) *
                100;
      }

      setState(() {
        _attempts = attempts;
        _bestScore = best;
        _averageScore =
            attempts.isEmpty
                ? 0
                : totalPercentage /
                    attempts.length;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice History',
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                        children: [
                          _StatTile(
                            title:
                                'Attempts',
                            value:
                                _attempts.length
                                    .toString(),
                          ),
                          _StatTile(
                            title:
                                'Best Score',
                            value:
                                _bestScore
                                    .toString(),
                          ),
                          _StatTile(
                            title:
                                'Average',
                            value:
                                '${_averageScore.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Expanded(
                    child: _attempts
                            .isEmpty
                        ? const Center(
                            child: Text(
                              'No practice attempts yet.',
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                _attempts
                                    .length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final attempt =
                                  _attempts[
                                      index];

                              return Card(
                                child:
                                    ListTile(
                                  leading:
                                      const Icon(
                                    Icons
                                        .history,
                                  ),
                                  title: Text(
                                    '${attempt['score']} / ${attempt['total_questions']}',
                                  ),
                                  subtitle:
                                      Text(
                                    attempt['created_at']
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatTile
    extends StatelessWidget {
  final String title;

  final String value;

  const _StatTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          value,
          style:
              const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}