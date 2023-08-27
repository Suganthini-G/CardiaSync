import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EcgPlot extends StatelessWidget {
  const EcgPlot({
    required this.signals,
    required this.min,
    required this.max,
  });

  final List<double> signals;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final int indexFor10Percent = (signals.length * 0.25).toInt();

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: SfCartesianChart(
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          enableDoubleTapZooming: false,
          enableSelectionZooming: false,
        ),
        primaryXAxis: NumericAxis(
          // Set the visible range for the x-axis
          visibleMinimum: 0,
          visibleMaximum: indexFor10Percent.toDouble(),
        ),
        primaryYAxis: NumericAxis(
          minimum: min, // Set the minimum value for the y-axis
          maximum: max,
        ),
        series: <LineSeries<ChartSampleData, double>>[
          LineSeries<ChartSampleData, double>(
            dataSource: signals
                .asMap()
                .entries
                .map((entry) => ChartSampleData(
                      x: entry.key.toDouble(),
                      y: entry.value,
                    ))
                .toList(),
            xValueMapper: (ChartSampleData data, _) => data.x,
            yValueMapper: (ChartSampleData data, _) => data.y,
          ),
        ],
      ),
    );
  }
}

class ChartSampleData {
  final double x;
  final double y;

  ChartSampleData({required this.x, required this.y});
}