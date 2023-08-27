import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:flutter_test_application_1/page/Testing_Files/File_Screen.dart';

class FileUpload extends StatefulWidget {
  const FileUpload({Key? key}) : super(key: key);

  @override
  FileUploadState createState() => FileUploadState();
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      final metadata = SettableMetadata(contentType: 'text/csv');

      return ref.putFile(file, metadata);
    } on FirebaseException {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException {
      return null;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(path);
      await ref.delete();
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

}

class FileUploadState extends State<FileUpload> {
  UploadTask? task;
  File? file;
  GlobalKey<FormState> RformKey = GlobalKey<FormState>();
  var _filename;
  double _uploadPercentage = 0;

  @override
  Widget build(BuildContext context) {
     var fileName = file != null ? basename(file!.path) : 'No File Selected';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test File Upload',
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: RformKey,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "File Name: "),
                    validator: (username) {
                      if (username.toString().trim().isEmpty) {
                        return "Please fill out this field";
                      }
                      return null;
                    },
                    initialValue: _filename,
                    onChanged: (value) => _filename = value,
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: selectFile, 
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, size: 20),
                      SizedBox(width: 8),
                      Text('Select File'),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  fileName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 28),
                if (_uploadPercentage > 0 && _uploadPercentage < 100)
                  LinearProgressIndicator(value: _uploadPercentage / 100),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => uploadAndNavigate(context), 
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Upload File'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadAndNavigate(BuildContext context) async {
    if (file == null) return;

      final fileName = basename(file!.path);
    final destination = 'Test_Files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    task!.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      setState(() {
        _uploadPercentage = progress * 100;
      });
    });

    await task!.whenComplete(() {});

    final snapshot = await task!.snapshot;
    final urlDownload = await snapshot.ref.getDownloadURL();

    Map<String, dynamic> uploadData = {
      "FileName": _filename,
      "Path": urlDownload,
    };

    await FirebaseFirestore.instance.collection("TestFiles").add(uploadData);

    setState(() {
      _uploadPercentage = 0;
      _filename = '';
      file = null;
      RformKey.currentState?.reset();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileScreen(),
      ),
    );
  }

  

}
