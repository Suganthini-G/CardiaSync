import 'package:flutter/material.dart';
import 'package:flutter_test_application_1/page/Testing_Files/File_Upload.dart';
import 'File_View.dart';

class FileScreen extends StatefulWidget {

  
  const FileScreen({Key? key}) : super(key: key);
 
  @override
  State<StatefulWidget> createState() {
    return FileScreenState();
  }
}

class FileScreenState extends State<FileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test ECG',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => ), 
          //   );
          },
        ),
      ),
      body: SingleChildScrollView( 
        child: FileView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileUpload(),
            ),
          )
        },
        label: const Text('Import File'),
        icon: const Icon(Icons.upload),
        backgroundColor: Color.fromARGB(255, 246, 145, 145),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
