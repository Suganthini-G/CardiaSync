import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeaturePlot extends StatelessWidget {
  final List<List<double>> reshapedData;
  final double min;
  final double max;

  FeaturePlot({
    required this.reshapedData,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
maxX: reshapedData.isNotEmpty && reshapedData[0].isNotEmpty
    ? reshapedData[0].length.toDouble() - 1
    : 0,          minY: min,
          maxY: max,
          lineBarsData: [
            for (int i = 0; i < reshapedData.length; i++)
              if (i == 2 ) // Plot only the first 10 rows
                LineChartBarData(
                  spots: List.generate(
                    reshapedData[i].length,
                    (index) => FlSpot(index.toDouble(), reshapedData[i][index]),
                  ),
                  isCurved: false,
                  color: Colors.blue, // You can customize the colors here
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
          ],
        ),
      ),
    );
  }
}
