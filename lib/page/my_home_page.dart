import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_application_1/core/card_decorations.dart';
import 'package:flutter_test_application_1/main.dart';
import 'package:flutter_test_application_1/page/patients/fetch_patient_data.dart';
import 'package:flutter_test_application_1/page/patients/insert_patient_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'Testing_Files/File_Screen.dart';
import '../widget/menu_card.dart';
import 'patients/ecg/real_time_ecg_graph.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    /*
    SystemChrome.setPreferredOrientations([
       DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
*/
     return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(MyApp.title), centerTitle: true),
        body:SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'CardiaSync IoT Monitor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            Center( 
              child: Container(
                width: 200, // Set the desired width
                height: 200, // Set the desired height
                child: Image.asset('assets/images/ecg-beat.png'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
           
            const SizedBox(
              width: 20,
            ),

            const Row(
              children: [
                SizedBox(width: 30), 
                Expanded(child: 
                  MenuCard(menuItem: "Add Patient", imageUrl: "assets/images/patient-add.png",routeUrl:InsertPatientData(), // Use an anonymous function
),
                ),

                SizedBox(width: 30),        
                      // Add some spacing between the containers
                Expanded(child: 
                  MenuCard(menuItem: "Patient Data", imageUrl: "assets/images/red_beat.png",routeUrl: FetchPatientData() ),
                ),

                SizedBox(width: 30), // Add some spacing between the containers

              ],
            ),

                const SizedBox(height: 30), // Add some spacing between the containers

             const Row(
              children: [
                SizedBox(width: 30),              // Add some spacing between the containers
                Expanded(child: 
                  MenuCard(menuItem: "Import ECG", imageUrl: "assets/images/import-ecg.png",routeUrl: FileScreen()),
                ),
                 SizedBox(width: 30), 
                Expanded(child: 
                  MenuCard(menuItem: "Analysis Report", imageUrl: "assets/images/patient-report.png", routeUrl: FetchPatientData()),
                ),

                SizedBox(width: 30), // Add some spacing between the containers


              ],
            ),
           
            const SizedBox(
              height: 30,
            ),

           
/*
            MaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const FetchPatientData()));
              },
              child: const Text('Fetch Data'),
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: 300,
              height: 40,
            ),
             
            MaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const EcgGraph()));
              },
              child: const Text('RealTime ECG Data'),
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: 300,
              height: 40,
            ),

            */


          ],
        ),
      ),
      ),
    );     
  }
}