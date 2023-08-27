import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test_application_1/core/full_ecg_data.dart';
import 'package:flutter_test_application_1/page/patients/ecg/real_time_prediction.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealTimeEcgGraph extends StatefulWidget {
  const RealTimeEcgGraph({Key? key,required this.patientKey, required this.ecgIndex}) : super(key: key);

  final String patientKey;
  final int ecgIndex;



  @override
  State<RealTimeEcgGraph> createState() => _RealTimeEcgGraphState();
}

class _RealTimeEcgGraphState extends State<RealTimeEcgGraph> {
  late List<LiveData> chartData;
  List<LiveData> allIncomingEcgData = [];

  late ChartSeriesController _chartSeriesController;

  late List<FullEcgData> ecgAllData=[];

  late DatabaseReference dbRefPatients;
  late DatabaseReference dbRefRealTimeECG;
  late DatabaseReference dbRefPatientsECG;

  String isBeginEcg = "false"; 
  int lastEcgIndex =0;
  bool iotConnect=false;
  int lastXValue = 0;
  bool isIotStop=false;

  @override
  void initState() {
    dbRefPatients = FirebaseDatabase.instance.ref().child('Patients').child(widget.patientKey).child('ecg').child(widget.ecgIndex.toString());
    dbRefRealTimeECG = FirebaseDatabase.instance.ref().child('RealTimeECG');

    super.initState();

    dbRefRealTimeECG.onValue.listen((event) {
      final Map<dynamic, dynamic>? snapshotValue = event.snapshot.value as Map<dynamic, dynamic>?;
      if (snapshotValue != null) {
        setState(() {
          iotConnect = snapshotValue['iotConnect'] == true;
          isBeginEcg = (snapshotValue['isBeginEcg'] == "true") as String;
        });
      }
    });

    chartData = [];
    getRealtimeEcgData();
      
    dbRefPatients.onValue.listen((event) {
      final dynamic data = event.snapshot.value;

      if (data != null && iotConnect) {
        final dynamic ecgData = data as Map<dynamic, dynamic>; // Update to 'ecgData'
        final List<dynamic>? ecgValues = ecgData['value'] as List<dynamic>?; // Update to 'value'
        if (ecgValues != null) {
          for (int j = 0; j < ecgValues.length; j++) {
            chartData.add(LiveData(lastXValue, ecgValues[j] / 1000));
            lastXValue += 2;
            ecgAllData.add(FullEcgData(lastXValue, ecgValues[j]*1.0));
            
            if (chartData.length > 1440) {
              chartData.removeAt(0);
            }        
            
          }
          setState(() {});
        }
      }
    }
  );
}
 
  void startEcg() {
    setState(() {
      isBeginEcg = "true";
      lastXValue = 0;
      isIotStop=false;

    });
    updateIsBeginEcg(isBeginEcg); // Update the value in the database
    //getRealtimeEcgData();
  }

  void stopEcg() {
    setState(() {
      isBeginEcg = "false";
      lastXValue = 0;
      isIotStop=true;
    });
    updateIsBeginEcg(isBeginEcg);
    print(ecgAllData); // Update the value in the database
  }

Future<void> getRealtimeEcgData() async {
    dbRefPatientsECG= FirebaseDatabase.instance.ref().child('Patients').child(widget.patientKey).child('ecg').child(widget.ecgIndex.toString());
    dbRefPatientsECG.onChildAdded.listen((event) {
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> ecgData = snapshot.value as Map<dynamic, dynamic>;
      int time = ecgData['time'];
      double speed = ecgData['speed'];
        //LiveData newData = LiveData(time, speed);
        //allIncomingEcgData.add(newData);
        //print(allIncomingEcgData);

      setState(() {
        chartData.add(LiveData(time, speed));
        lastXValue=  time;
        ecgAllData.add(FullEcgData(time, speed));
          print('Added data to ecgAllData: $ecgAllData'); // Add this line
        });
    }
  });

  dbRefPatientsECG.onChildRemoved.listen((event) {
    setState(() {
      chartData.clear();
    });
  });
}





void updateIsBeginEcg(String value) {
  DatabaseReference realTimeEcgRef = dbRefRealTimeECG;

  realTimeEcgRef.update({
    'patient_key':widget.patientKey,
    'isBeginEcg': value,
    'ecgIndex':widget.ecgIndex,
    'dateTime':DateFormat.yMd().add_jm().format(DateTime.now()).toString(),
  }).then((_) {
    print('isBeginEcg updated successfully.');
  }).catchError((error) {
    print('Failed to update isBeginEcg: $error');
  });
  getRealtimeEcgData();
}

void _showNoDataDialog(String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No ECG Data'),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
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
      appBar: AppBar(title: Text('ECG Graph'), centerTitle: true),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: !iotConnect ? startEcg : null,
                child: Text('Start'),
              ),
              SizedBox(
                width: 15,
              ),
              ElevatedButton(
                onPressed: iotConnect ? stopEcg : null,
                child: Text('Stop'),
              ),
              SizedBox(
                width: 15,
              ),
              MaterialButton(
                  onPressed: isIotStop
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RealTimePrediction(
                                patientKey: widget.patientKey,
                                allIncomingEcgData: ecgAllData,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Go To Prediction'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  minWidth: 150,
                  height: 40,
                ),

            ],
          ),

             
          Visibility(
            visible: !iotConnect,
            child: Center(
              child: Text('Press Start. Waiting for connect...'),
            ),
          ),
          Visibility(
            visible: iotConnect,
            child:     
            Expanded(
              child: SfCartesianChart(
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
          ),
        ],
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
