import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
 
class InsertPatientData extends StatefulWidget {
  const InsertPatientData({Key? key}) : super(key: key);
 
  @override
  State<InsertPatientData> createState() => _InsertPatientDataState();
}


 
class _InsertPatientDataState extends State<InsertPatientData> {
  
  final  patientNameController = TextEditingController();
  final  patientAgeController= TextEditingController();
  final  patientMobileController =TextEditingController();
 
  late DatabaseReference dbRef;
  bool res=false;
 
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Patients');
  }
 
 void _showDialog(String type,String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          
          title: Text(type),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if(type=="success"){
                  _clearTextFields(); // Clear text fields after successful submission
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    patientNameController.clear();
    patientAgeController.clear();
    patientMobileController.clear();
  }

   bool _validateFields() {
    if (patientNameController.text.trim().isEmpty ||
        patientAgeController.text.trim().isEmpty ||
        patientMobileController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'), centerTitle: true,
      ),
      body: SingleChildScrollView(child: 
        Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Adding Patient\'s Data',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: patientNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Enter Patient Name',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: patientAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Age',
                    hintText: 'Enter Patient Age',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: patientMobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile No',
                    hintText: 'Enter Patient Mobile No',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  onPressed: () {
                     if (_validateFields()) {
                      Map<String, String> patients = {
                        'name': patientNameController.text,
                        'age': patientAgeController.text,
                        'mobile': patientMobileController.text,
                      };

                      dbRef.push().set(patients).then((_) {
                        _showDialog("success","Patient Added Successfully"); // Show success dialog
                      }); 
                    }
                    else{
                      _showDialog("warn",'All fields are required.');
                    }
                  },
                  child: const Text('Add Patient'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  minWidth: 300,
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}