import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_application_1/page/Testing_Files/ecg_classification.dart';

class FileList extends StatefulWidget {
  final String FileName;
  final String url;

  const FileList({
    required this.FileName,
    required this.url,
    Key? key,
  }) : super(key: key);

  @override
  _FileListState createState() =>
      _FileListState();
}

class _FileListState extends State<FileList> {

void printLabels() async {
  final labels = await rootBundle.loadString('new/label.txt');

  print(labels.toString());
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Column(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      widget.FileName,
                      style: TextStyle(
                        color: Color(0xff1E1C61),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => deleteFileAndDetails(widget.FileName),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        MaterialButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => ECGClassification(
                                fileUrl: widget.url,
                              ),
                            ),
                          ),
                          child: Text(
                            "Predict",
                            style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteFileAndDetails(String FileName) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this file?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      
         final storageRef = FirebaseStorage.instance.refFromURL(widget.url);
      await storageRef.delete();
      
      await FirebaseFirestore.instance
          .collection("TestFiles")
          .where("FileName", isEqualTo: FileName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      setState(() {
        FileName = '';
      });

    }
  }

}
