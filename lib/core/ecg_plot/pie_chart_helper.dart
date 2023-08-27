import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartHelper {
  static List<PieChartSectionData> generatePieChartData(
      List<int> predictions, List<String> labels) {
    List<PieChartSectionData> pieChartData = [];

    List<Color> predefinedColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    Map<int, int> classCounts = Map();
    for (var prediction in predictions) {
      classCounts[prediction] = (classCounts[prediction] ?? 0) + 1;
    }

    classCounts.forEach((classIndex, count) {
      pieChartData.add(PieChartSectionData(
        value: count.toDouble(),
        title: '${labels[classIndex]}: $count',
        color: predefinedColors[classIndex % predefinedColors.length],
      ));
    });

    return pieChartData;
  }
}
