import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/performance_history_model.dart';

class PerformanceChart extends StatelessWidget {
  final List<PerformanceHistoryModel> data;

  const PerformanceChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'No performance data available',
          ),
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
          ),

          borderData: FlBorderData(
            show: false,
          ),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20,
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget:
                    (value, meta) {
                  final index =
                      value.toInt();

                  if (index < 0 ||
                      index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      'A${index + 1}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData:
                LineTouchTooltipData(
              getTooltipItems:
                  (spots) {
                return spots.map(
                  (spot) {
                    final exam =
                        data[spot.x.toInt()];

                    return LineTooltipItem(
                      '${exam.examTitle}\n${exam.score.toStringAsFixed(0)}%',
                      const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    );
                  },
                ).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) {
                  return FlSpot(
                    index.toDouble(),
                    data[index].score,
                  );
                },
              ),

              isCurved: true,

              barWidth: 4,

              dotData: FlDotData(
                show: true,
              ),

              belowBarData:
                  BarAreaData(
                show: true,
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end: Alignment
                      .bottomCenter,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(
                          alpha: 0.25,
                        ),
                    Colors
                        .transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}