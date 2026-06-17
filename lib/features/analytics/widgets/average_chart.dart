import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AverageChart
    extends StatelessWidget {

  const AverageChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 70),
                FlSpot(2, 75),
                FlSpot(3, 85),
                FlSpot(4, 90),
              ],
            ),
          ],
        ),
      ),
    );
  }
}