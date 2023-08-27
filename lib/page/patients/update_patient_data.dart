import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
 
class UpdatePatientData extends StatefulWidget {
  
  const UpdatePatientData({Key? key, required this.patientKey}) : super(key: key);
 
  final String patientKey;
 
  @override
  State<UpdatePatientData> createState() => _UpdatePatientDataState();
}
 
class _UpdatePatientDataState extends State<UpdatePatientData> {
 
  final  patientNameController = TextEditingController();
  final  patientAgeController= TextEditingController();
  final  patientMobileController =TextEditingController();
 
  late DatabaseReference dbRef;
 
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Patients');
    getpatientData();
  }
 
  void getpatientData() async {
    DataSnapshot snapshot = await dbRef.child(widget.patientKey).get();
 
    Map patient = snapshot.value as Map;
 
    patientNameController.text = patient['name'];
    patientAgeController.text = patient['age'];
    patientMobileController.text = patient['mobile'];
 
  }
  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Updating Record'), centerTitle: true,
      ),
      body:  SingleChildScrollView(child: 
      Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Updating patient data',
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
 
                  Map<String, String> Patients = {
                    'name': patientNameController.text,
                    'age': patientAgeController.text,
                    'mobile': patientMobileController.text
                  };
 
                  dbRef.child(widget.patientKey).update(Patients)
                  .then((value) => {
                     Navigator.pop(context) 
                  });
 
                },
                child: const Text('Update Data'),
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