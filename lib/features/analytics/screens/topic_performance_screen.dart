import 'package:flutter/material.dart';

import '../services/topic_analytics_service.dart';

class TopicPerformanceScreen
    extends StatefulWidget {
  const TopicPerformanceScreen({
    super.key,
  });

  @override
  State<TopicPerformanceScreen>
      createState() =>
          _TopicPerformanceScreenState();
}

class _TopicPerformanceScreenState
    extends State<TopicPerformanceScreen> {
  final _service =
      TopicAnalyticsService();

  bool _loading = true;

  List<Map<String, dynamic>>
      _topics = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results =
        await _service
            .getTopicPerformance();

    if (!mounted) return;

    setState(() {
      _topics = results;
      _loading = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topic Performance',
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              itemCount:
                  _topics.length,
              itemBuilder:
                  (context, index) {
                final topic =
                    _topics[index];

                final average =
                    topic['average']
                        as double;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${average.toInt()}%',
                      ),
                    ),
                    title: Text(
                      topic['topic'],
                    ),
                    subtitle: Text(
                      average < 60
                          ? 'Needs Improvement'
                          : average < 80
                              ? 'Good'
                              : 'Excellent',
                    ),
                  ),
                );
              },
            ),
    );
  }
}