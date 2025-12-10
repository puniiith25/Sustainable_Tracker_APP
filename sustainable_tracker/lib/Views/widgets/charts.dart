import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlySavingsChartSimpleTitles extends StatelessWidget {
  const MonthlySavingsChartSimpleTitles({super.key});

  final List<double> data = const [
    3.5,
    5,
    6,
    5.5,
    8.5,
    7.0,
    9.5,
    10.5,
    12,
    15,
    13,
  ];

  @override
  Widget build(BuildContext context) {
    final double minY = 0;
    final double maxY = 16;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Savings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left vertical label (rotated)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 20),
                  child: Transform.rotate(
                    angle: -1.5708,
                    child: const Text(
                      'kg CO₂',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 2,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.25),
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.12),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              // RETURN A PLAIN WIDGET (compatible across versions)
                              getTitlesWidget: (value, meta) =>
                                  _buildBottomTitle(value, meta),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 4,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                // only show labels for certain ticks
                                if (value % 4 != 0)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            top: BorderSide(color: Colors.transparent),
                            right: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              data.length,
                              (i) => FlSpot(i.toDouble(), data[i]),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.green.shade700,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.green.shade700,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (spot) =>
                                Colors.green.shade700.withOpacity(0.95),
                            getTooltipItems: (spots) => spots.map((s) {
                              return LineTooltipItem(
                                '${s.y.toStringAsFixed(1)} kg',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build bottom axis labels as plain widgets (no SideTitleWidget)
  static Widget _buildBottomTitle(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, color: Colors.black54);
    final labels = [
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final i = value.toInt();
    if (i < 0 || i >= labels.length) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(labels[i], style: style),
    );
  }
}
