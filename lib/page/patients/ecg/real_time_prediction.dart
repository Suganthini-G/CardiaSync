import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_application_1/core/ecg_plot/ecg_plot.dart';
import 'package:flutter_test_application_1/core/ecg_plot/feature_plot.dart';
import 'package:flutter_test_application_1/page/patients/ecg/predicted_ecg_plot.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../core/ecg_plot/pie_chart_helper.dart';
import '../../../core/full_ecg_data.dart';

class RealTimePrediction extends StatefulWidget {
  const RealTimePrediction({Key? key,required this.patientKey, required this.allIncomingEcgData}) : super(key: key);

  final String patientKey;
  final List<FullEcgData> allIncomingEcgData;

  @override
  State<RealTimePrediction> createState() => _RealTimePredictionState();
}

class _RealTimePredictionState extends State<RealTimePrediction> {
    late final List<double> signals;

   List<double> denoisedSignals = [];
  List<double> zScores = [];
  int windowSize = 180; 
  List<List<double>> reshapedZScores = [];
  late Interpreter _interpreter;
  List<String> _labels = [];

  List<int> predictedCategories = [];
  late List<int> highPointIndices=[];
  List<PieChartSectionData> pieChartData = [];

  List<PredictedEcgPlot> ecgPlots = [];
  late List<int> predictions = [];

  bool isChartVisible = false;
bool isPredictedEcgVisible = false;



  @override
  void initState() {
    super.initState();
    preProcessingData();
    loadTFLiteModel();
  }
  Future<void> preProcessingData() async {
     List<double> speedSignals = widget.allIncomingEcgData.map((data) => data.speed).toList();
    setState(() {
      signals = speedSignals; // Store the speed data in the 'signals' list
    });

    //List<double> doubleSignals = signals.map((value) => value.toDouble()).toList();
    denoisedSignals = denoise(speedSignals,10);

    zScores = calculateZScores(denoisedSignals);
    
    reshapedZScores = reshapeZScores(zScores,  360);

    }
 

  List<double> denoise(List<double> data, int windowSize) {
  List<double> denoisedData = [];

  for (int i = 0; i < data.length; i++) {
    int startIndex = i - windowSize ~/ 2;
    int endIndex = i + windowSize ~/ 2;

    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex >= data.length) {
      endIndex = data.length - 1;
    }

    double sum = 0;
    int count = 0;
    for (int j = startIndex; j <= endIndex; j++) {
      sum += data[j];
      count++;
    }

    double average = sum / count;
    denoisedData.add(average);
  }

  return denoisedData;
}


  List<double> calculateZScores(List<double> data) {
    double sum = 0;
    for (var value in data) {
      sum += value;
    }
    double mean = sum / data.length;

    double sumOfSquaredDifferences = 0;
    for (var value in data) {
      double difference = value - mean;
      sumOfSquaredDifferences += difference * difference;
    }
    double standardDeviation = sqrt(sumOfSquaredDifferences / (data.length - 1));

    List<double> zScores = [];
    for (var value in data) {
      double zScore = (value - mean) / standardDeviation;
      zScores.add(zScore);
    }

    setState(() {
      this.zScores = zScores;
    });

    return zScores;
  }

 List<List<double>> reshapeZScores(List<double> zScores, int windowSize) {
  List<List<double>> reshapedData = [];
  double threshold = 3.0; // You can adjust this threshold as needed

  for (int i = 1; i < zScores.length - 1; i++) {
    if (zScores[i] > threshold &&
        zScores[i] > zScores[i - 1] &&
        zScores[i] > zScores[i + 1]) {
      highPointIndices.add(i);
    }
  }

    print("**********R peak count************");
    print(highPointIndices.length);

  for (int highIndex in highPointIndices) {
    int startIndex = highIndex - windowSize ~/ 2;
    int endIndex = highIndex + windowSize ~/ 2 - 1; // Adjust for 360 points

    if (startIndex < 0) {
      endIndex += -startIndex; // Adjust endIndex for edge case
      startIndex = 0;
    }
    if (endIndex >= zScores.length) {
      startIndex -= endIndex - (zScores.length - 1); // Adjust startIndex for edge case
      endIndex = zScores.length - 1;
    }

    List<double> rowData = [];
    for (int j = startIndex; j <= endIndex; j++) {
      rowData.add(zScores[j]);
    }

    reshapedData.add(rowData);
  }

  
  setState(() {
      this.highPointIndices = highPointIndices;
    });

  return reshapedData;
}


Future<void> loadTFLiteModel() async {
  String modelPath = 'assets/transformer_model.tflite';
  _interpreter = await Interpreter.fromAsset(modelPath);

  String labels = await rootBundle.loadString('assets/label.txt');
  _labels = labels.split('\n');
  print(_labels);
}


Future<void> predictAndDisplayPieChart() async {
  List<List<double>> inputData = reshapedZScores;
  List<List<double>> outputData = [];

  for (var input in inputData) {
    var inputTensor = Float32List.fromList(input.expand((value) => [value]).toList());
    var outputTensor = Float32List(1 * _labels.length);
    _interpreter.run(inputTensor.buffer, outputTensor.buffer);

    var reshapedOutput = List.generate(1, (i) {
      var start = i * _labels.length;
      var end = start + _labels.length;
      return outputTensor.sublist(start, end);
    });

    outputData.addAll(reshapedOutput);
  }

  for (var output in outputData) {
    int prediction = output.indexOf(output.reduce((max)));
    predictions.add(prediction);
  }


  List<PieChartSectionData> pieChartData = PieChartHelper.generatePieChartData(predictions, _labels);

  setState(() {
    this.pieChartData = pieChartData;
    this.predictions=predictions;
      isChartVisible = true; // Show the pie chart
    isPredictedEcgVisible = true; // Show the predicted ECG graph
  });
}

@override
Widget build(BuildContext context) {
  return  SafeArea(child: 
    Scaffold(
      appBar: AppBar(
        title: Text('ECG Results'), centerTitle: true,
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),

              // Real ECG Graph
              Text(
                'Real ECG Graph',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              EcgPlot(signals: signals, min: 0, max: 4500),

              // ECG Graph after Denoised
              Text(
                'ECG Graph after Denoising',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              EcgPlot(signals: denoisedSignals, min: 0, max: 4000),

              // ECG Graph Z score normalization
              Text(
                'ECG Graph after Z-score Normalization',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              EcgPlot(signals: zScores, min: -2, max: 7),

              // Feature Extraction
              Text(
                'Feature Extraction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              FeaturePlot(reshapedData: reshapedZScores, min: -2, max: 8),

              SizedBox(height: 20),

              Text(
                'Final Prediction Result',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              SizedBox(height: 5),

              // Prediction Button
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: predictAndDisplayPieChart,
                child: Text('Get Prediction Result'),
              ),

              SizedBox(height: 30),

              // Predicted ECG Plot and Pie Chart (if visible)
              if (isChartVisible)
                Column(
                  children: [

                    // Predicted ECG Plot
                    if (isPredictedEcgVisible)
                      PredictedEcgPlot(
                        signals: zScores,
                        highPointIndices: highPointIndices,
                        max: 7,
                        min: -2,
                        predictionsValue: predictions,
                      ),

                    SizedBox(height: 20),
                    
                    Text(
                      "Total Number of beat : "+highPointIndices.length.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 53, 47, 47),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Pie Chart displaying classification results
                    AspectRatio(
                      aspectRatio: 2.5,
                      child: PieChart(
                        PieChartData(
                          sections: pieChartData,
                        ),
                      ),
                    ),

                   
              SizedBox(height: 5),

                    SizedBox(height: 40),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
    
  );
}



}





class ChartSampleData {
  final double x;
  final double y;

  ChartSampleData({required this.x, required this.y});
}