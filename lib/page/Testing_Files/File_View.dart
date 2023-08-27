import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'File_List.dart';

class FileView extends StatelessWidget {
  const FileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('TestFiles')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return !snapshot.hasData
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot data = snapshot.data.docs[index];
                  return FileList(
                    FileName: data['FileName'],
                    url: data['Path'],
                  );
                },
              );
      },
    );
  }
}
