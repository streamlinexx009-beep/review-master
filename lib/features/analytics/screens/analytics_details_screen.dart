import 'package:flutter/material.dart';

import '../widgets/average_chart.dart';

class AnalyticsDetailsScreen
    extends StatelessWidget {

  const AnalyticsDetailsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Analytics Details',
        ),
      ),
      body: const Padding(
        padding:
            EdgeInsets.all(16),
        child: AverageChart(),
      ),
    );
  }
}