import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_application_1/core/card_decorations.dart';
import 'package:flutter_test_application_1/page/patients/update_patient_data.dart';

import 'ecg/real_time_ecg_graph.dart';
import 'ecg/view_ecg_graph.dart';
//import 'package:flutter_firebase_series/screens/update_record.dart';
 
class FetchPatientData extends StatefulWidget {
  const FetchPatientData({Key? key}) : super(key: key);
 
  @override
  State<FetchPatientData> createState() => _FetchPatientDataState();
}
 
class _FetchPatientDataState extends State<FetchPatientData> {
  int ecgIndex=0;  
  Query dbRef = FirebaseDatabase.instance.ref().child('Patients');
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('Patients');
  
  Widget listItem({required Map patient}) {
    return SingleChildScrollView(child: 
    GestureDetector(
      onTap: () {
        /*
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => routeUrl, // Replace YourNextPage with the actual destination page
          ),
        );
        */
      },
      child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(5),
          decoration: CardDecorations.boxDecoration,
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 75,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        /*image: DecorationImage(
                          image: AssetImage("assets/images/import-ecg.png"),
                          fit: BoxFit.fill,
                        ),*/
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: 
                  Column(children: [
                    MaterialButton(
                      onPressed: () {
                         if(patient.containsKey('ecg')){
                          ecgIndex=patient['ecg'].length;
                         }
                         else{
                           ecgIndex=0;
                         }
                         
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RealTimeEcgGraph(patientKey: patient['key'], ecgIndex:ecgIndex)));
                      },
                      child: const Text(
                        'Take ECG',                    
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                      minWidth: 200,
                      height: 30,
                    ),
                   
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewEcgGraph(patientKey: patient['key'])));
                      },
                      child: const Text(
                        'View Last ECG',                    
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.blue,
                      textColor: Colors.white,
                      minWidth: 200,
                      height: 30,
                    ),
                  ],
                  ),
                   
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,      
                    children: [
                      Text(
                        patient['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Age : "+patient['age'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Mobile : "+patient['mobile'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      
                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => UpdatePatientData(patientKey: patient['key'])));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          GestureDetector(
                            onTap: () {
                              reference.child(patient['key']).remove();
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red[700],
                                ),
                              ],
                            ),
                          ),              
                        ],
                      ), 
                        SizedBox(height: 80),
        
                    ],
                  ),      
                ), 

              ],
            ),
          ),
        ),
    ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: 
    Scaffold(
      appBar: AppBar(
        title: const Text('Patients Details'), centerTitle: true,
      ),
      body: 
      Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
 
            Map patient = snapshot.value as Map;
            patient['key'] = snapshot.key;
 
            return listItem(patient: patient);
 
          },
        ),
      ),
      ),
    
    );
  }
}