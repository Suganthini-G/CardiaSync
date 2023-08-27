import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;

class ECGClassification extends StatefulWidget {
  final String fileUrl; 

  ECGClassification({required this.fileUrl, Key? key}) : super(key: key);

  @override
  _ECGClassificationState createState() => _ECGClassificationState();
}

class _ECGClassificationState extends State<ECGClassification> {
  List<int> signals = [];
  List<double> denoisedSignals = [];
  List<double> zScores = [];
  List<PieChartSectionData> pieChartData = [];
  List<BarChartGroupData> barChartData = [];
  int windowSize = 180; 
  List<List<double>> reshapedZScores = [];
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    loadCSVData();
    loadTFLiteModel();
  }

  Future<void> loadCSVData() async {
    final response = await http.get(Uri.parse(widget.fileUrl)); 

  if (response.statusCode == 200) {
    final csvData = response.body;

    List<String> rows = csvData.split('\n');
    if (rows.isNotEmpty) {
      List<String> firstRowColumns = rows.first.split(',');
      if (firstRowColumns.isNotEmpty && int.tryParse(firstRowColumns[0]) != null) {
        for (String row in rows) {
            List<String> columns = row.split(',');
            if (columns.length >= 1) {
              signals.add(int.parse(columns[0]));
            }
        }
      } else {
        for (String row in rows.skip(1)) {
          if (row.isNotEmpty) {
            List<String> columns = row.split(',');
            if (columns.length >= 2) {
              signals.add(int.parse(columns[1]));
            }
          }
        }
      }
    }
  }


      print(signals.length);

    List<double> doubleSignals = signals.map((value) => value.toDouble()).toList();
    denoisedSignals = denoise(doubleSignals,5);

    zScores = calculateZScores(denoisedSignals);
    
    reshapedZScores = reshapeZScores(zScores, 360);

    setState(() {});
    
    print(reshapedZScores.length);
    print(reshapedZScores[0].length);
    print(reshapedZScores);
  }

  List<List<double>> reshapeData(List<double> data, int sequenceLength) {
  int numSamples = data.length;

  List<List<double>> reshapedData = [];

  for (int i = 0; i < numSamples - sequenceLength + 1; i++) {
    List<double> sampleSequence = data.sublist(i, i + sequenceLength);
    reshapedData.add(sampleSequence);
  }
  return reshapedData;
}

List<List<double>> reshapeZScores(List<double> zScores, int windowSize) {
  List<List<double>> reshapedData = [];
  double threshold = 3.0; // You can adjust this threshold as needed

  List<int> highPointIndices = [];
  for (int i = 1; i < zScores.length - 1; i++) {
    if (zScores[i] > threshold &&
        zScores[i] > zScores[i - 1] &&
        zScores[i] > zScores[i + 1]) {
      highPointIndices.add(i);
    }
  }

    print("*********R peak count***********");
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

  return reshapedData;
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

    return zScores;
  }

//  List<List<double>> reshapeZScores(List<double> zScores, int numRows, int numColumns) {
//   List<List<double>> reshapedData = [];

//   int currentIndex = 0;
//   for (int i = 0; i < numRows; i++) {
//     List<double> row = [];
//     for (int j = 0; j < numColumns; j++) {
//       if (currentIndex < zScores.length) {
//         row.add(zScores[currentIndex]);
//         currentIndex++;
//       } else {
//         row.add(0.0);
//       }
//     }
//     reshapedData.add(row);
//   }

//   return reshapedData;
// }

Future<void> loadTFLiteModel() async {
  String modelPath = 'assets/transformer_model.tflite';
  _interpreter = await Interpreter.fromAsset(modelPath);

  String labels = await rootBundle.loadString('assets/label.txt');
  _labels = labels.split('\n');
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

  List<int> predictions = [];
  for (var output in outputData) {
    int prediction = output.indexOf(output.reduce((max)));
    predictions.add(prediction);
  }

  Map<int, int> classCounts = Map();
    for (var prediction in predictions) {
     classCounts[prediction] = (classCounts[prediction] ?? 0) + 1;
  }

  print(predictions);

    List<PieChartSectionData> pieChartData = [];
    List<BarChartGroupData> newBarChartData = generateBarGroups(classCounts);

      List<Color> predefinedColors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
    ];

    classCounts.forEach((classIndex, count) {
    String label = '${_labels[classIndex]}: $count';
    double value = count.toDouble();
    Color color = predefinedColors[classIndex];
    double percentage = (value / predictions.length) * 100;
    
    pieChartData.add(PieChartSectionData(
      value: percentage,
      title: label,
      color: color,
    ));

  });

    setState(() {
      this.pieChartData = pieChartData;
      barChartData = newBarChartData;
    });
  }

  List<BarChartGroupData> generateBarGroups(Map<int, int> classCounts) {

      List<Color> predefinedColors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
    ];

  List<BarChartGroupData> barGroups = [];
  for (int i = 0; i < _labels.length; i++) {
   double value = classCounts[i]?.toDouble() ?? 0.0;
    barGroups.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value, 
             color: predefinedColors[i],
          ),
        ],
      ),
    );
  }
  return barGroups;
}




  @override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text('CSV Processing')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: predictAndDisplayPieChart,
                child: Text('Process Classification'),
              ),
              SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    barGroups: barChartData,
                    titlesData: FlTitlesData(show: true),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                for (var data in pieChartData)
                                Column(
                                    children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: data.color,
                                      ),
                                      SizedBox(width: 5),
                                      Text(data.title),
                                      Spacer(),
                                      Text('${data.value.toStringAsFixed(2)}%'),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                    ],
                                ),
                                    
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
    );
  }

}

       