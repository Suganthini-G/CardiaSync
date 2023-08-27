import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PredictedEcgPlot extends StatelessWidget {
  final List<double> signals;
  final List<int> highPointIndices;
  final List<int> predictionsValue;
  final List<String> labels=["Normal",
"Left bundle branch block beat",
"Right bundle branch block beat",
"Atrial premature beat",
"Premature ventricular contraction"];
  final double min;
  final double max;

  PredictedEcgPlot({
    Key? key,
    required this.signals,
    required this.min,
    required this.max,
    required this.highPointIndices,
    required this.predictionsValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int indexFor10Percent = (signals.length * 0.25).toInt();
List<CombinedData> combinedDataList = List.generate(
      signals.length,
      (index) => CombinedData(
        x: index.toDouble(),
        y: signals[index],
        predictionValue: highPointIndices.contains(index) ? predictionsValue[highPointIndices.indexOf(index)] : -1,
      ),
    );

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: Stack(
        children: [
        SfCartesianChart(
  zoomPanBehavior: ZoomPanBehavior(
    enablePanning: true,
    enablePinching: true,
    enableDoubleTapZooming: false,
    enableSelectionZooming: false,
  ),
  primaryXAxis: NumericAxis(
    visibleMinimum: 0,
    visibleMaximum: indexFor10Percent.toDouble(),
  ),
  primaryYAxis: NumericAxis(
    minimum: min,
    maximum: max,
  ),
   series: <CartesianSeries<CombinedData, double>>[
          LineSeries<CombinedData, double>(
            dataSource: combinedDataList,
            xValueMapper: (CombinedData data, _) => data.x,
            yValueMapper: (CombinedData data, _) => data.y,
          ),
          ScatterSeries<CombinedData, double>(
            dataSource: combinedDataList.where((data) => data.predictionValue >= 0).toList(),
            xValueMapper: (CombinedData data, _) => data.x,
            yValueMapper: (CombinedData data, _) => data.y,
            color: Colors.red,
            markerSettings: MarkerSettings(
              isVisible: true,
              width: 8,
              height: 8,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: 12, color: Colors.green),
              builder: (dynamic data, dynamic point, dynamic series, int dataIndex, int pointIndex) {
                return Text(
                  labels[data.predictionValue],
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 49, 164, 107)),
                );
              },
            ),
          ),
        ],
),



        ],
      ),
    );
  }
}



class CombinedData {
  final double x;
  final double y;
  final int predictionValue;

  CombinedData({required this.x, required this.y, required this.predictionValue});
}
