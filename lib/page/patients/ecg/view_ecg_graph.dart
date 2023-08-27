import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ViewEcgGraph extends StatefulWidget {
  const ViewEcgGraph({Key? key,required this.patientKey}) : super(key: key);

  final String patientKey;

  @override
  State<ViewEcgGraph> createState() => _ViewEcgGraphState();
}

class _ViewEcgGraphState extends State<ViewEcgGraph> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  final DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('Patients').child('ecg');
  late DatabaseReference dbRef;

  @override
  void initState() {
    dbRef = FirebaseDatabase.instance.ref().child('Patients');
    getpatientData();
    super.initState();
    chartData = []; // Initialize with empty data
    dbRef.onValue.listen((event) {
      final List<dynamic>? data = event.snapshot.value as List<dynamic>?;
      chartData.clear();
      if (data != null) {
        for (int i = 0; i < data.length; i++) {
          chartData.add(LiveData(i*2, data[i] / 1000));
        }
        setState(() {});
      }
    });
  }
void getpatientData() async {
  DatabaseReference patientRef = dbRef.child(widget.patientKey);
  DataSnapshot snapshot = await patientRef.get();

  Map<dynamic, dynamic>? patient = snapshot.value as Map<dynamic, dynamic>?;

  if (patient != null && patient.containsKey('ecg')) {
    List<dynamic>? ecgData = patient['ecg'];

    if (ecgData != null && ecgData.isNotEmpty) {
      List<dynamic> lastEcgRecord = ecgData.last['value'];

      if (lastEcgRecord != null && lastEcgRecord.isNotEmpty) {
        chartData.clear();

        for (int i = 0; i < lastEcgRecord.length; i++) {
          chartData.add(LiveData(i*2, lastEcgRecord[i] / 1000));
        }

        setState(() {});
      } else {
        _showNoDataDialog();
      }
    } else {
      _showNoDataDialog();
    }
  } else {
    _showNoDataDialog();
  }
}

void _showNoDataDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No ECG Data'),
        content: Text('There is no ECG data available for this patient.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Last ECG Graph'), centerTitle: true),
        body: SfCartesianChart(
          series: <SplineSeries<LiveData, int>>[
            SplineSeries<LiveData, int>(
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
              dataSource: chartData,
              color: const Color.fromRGBO(192, 108, 132, 1),
              xValueMapper: (LiveData data, _) => data.time,
              yValueMapper: (LiveData data, _) => data.speed,
            )
          ],
          primaryXAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.none,
            interval: 500,
            title: AxisTitle(text: 'Time (Milli Seconds)'),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 4.5,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            interval: 1,
            title: AxisTitle(text: 'ECG (Mbps)'),
          ),
        ),
      ),
    );
  }
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final double speed;
}
