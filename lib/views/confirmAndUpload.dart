import 'dart:async';
import 'dart:io';
import 'package:fire_project/views/viewMapOrReport.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/views/camera.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:fire_project/landingPage.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:fire_project/globalData/globalVariables.dart';

import 'mapRender.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

// ignore: camel_case_types
class confirmAndUpload extends StatelessWidget {
  final setImageData imageData;

  const confirmAndUpload({Key key, this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Image Upload", style: TextStyle(color: Color(Global.selectedIconColor))),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Center(
                child: Image.file(File(imageData.imagePath)),
              ),
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border.all(
                color: Colors.grey,
                width: 0.00,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.deepOrange[200], width: 3),
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: IconButton(
                icon: const Icon(Icons.check_circle),
                iconSize: 40,
                color: Colors.deepOrange[100],
                padding: EdgeInsets.all(.01),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Uploader(imageData: imageData),
                      transitionsBuilder:
                          (context, animation1, animation2, child) =>
                              FadeTransition(opacity: animation1, child: child),
                      transitionDuration: Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.deepOrange[200], width: 3),
                shape: BoxShape.circle,
                color: Colors.white60,
              ),
              child: IconButton(
                icon: const Icon(Icons.cancel),
                iconSize: 40,
                color: Colors.deepOrange[200],
                padding: EdgeInsets.all(.01),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          CameraApp(),
                      transitionsBuilder:
                          (context, animation1, animation2, child) =>
                              FadeTransition(opacity: animation1, child: child),
                      transitionDuration: Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
            ),
          ),

          // _compassDataWidget(),
          // _captureControlRowWidget(),
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final setImageData imageData;

  Uploader({Key key, this.imageData}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://fire-reporting-88f03.appspot.com');

  StorageUploadTask _uploadTask;
  String filePath;

  /// Starts an upload task
  void _startUpload() {
    /// Unique file name for the file
    final filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _storage
          .ref()
          .child(filePath)
          .putFile(File(widget.imageData.imagePath));
    });
  }

  Future<void> _uploadImageData() async {
    StorageTaskSnapshot taskSnapshot = await _uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    await Firestore.instance.collection("images").add({
      "url": downloadUrl,
      "name": widget.imageData.imagePath,
      "timeTaken": widget.imageData.timeTaken,
      "compassData": widget.imageData.compassData,
      "imagePosition": widget.imageData.imagePosition
    });
  }

  Widget _navigation(){
    return Column(
      children: [
        Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 80,
          child: RaisedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      MapRender(),
                  transitionsBuilder: (context, animation1,
                      animation2,
                      child) =>
                      FadeTransition(
                          opacity: animation1, child: child),
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            },
            color: Color(Global.selectedIconColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              //side: BorderSide(color: Colors.grey),
            ),
            label: Text(
              "View Image on Map",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            icon: Icon(Icons.map_outlined, size: 10),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
          height: 60,
          child: RaisedButton.icon(
            onPressed: () {
              int _currentIndex = 1;
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ViewMapOrReport(),
                  transitionsBuilder: (context, animation1,
                      animation2,
                      child) =>
                      FadeTransition(
                          opacity: animation1, child: child),
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            },
            color: Color(Global.selectedIconColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              //side: BorderSide(color: Colors.grey),
            ),
            label: Text(
              "Home",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            icon: Icon(Icons.home, size: 10),
          ),
        ),
      ],
    ),],
    );
  }

  Widget getUploadState() {
    if (_uploadTask != null) {
      /// Manage the task state and event subscription with a StreamBuilder
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;
            if (snapshot.error == null) {
              if (_uploadTask.isComplete) {
                _uploadImageData();
              }
            }

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
              children: [
                if (_uploadTask.isComplete)
            Stack(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(0.25),
                      child: Text('\nImage Upload Successful',
                          style: TextStyle(color: Color(Global.selectedIconColor), fontSize: 10)),
                    ),
                  ),

                  ],),
                _navigation(),

                if (_uploadTask.isPaused)
                  FlatButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: _uploadTask.resume,
                  ),

                if (_uploadTask.isInProgress)
                  FlatButton(
                    child: Icon(Icons.pause),
                    onPressed: _uploadTask.pause,
                  ),

                // Progress bar
                Stack(
                  children:  <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: LinearProgressIndicator(backgroundColor: Color(Global.iconColor), value: progressPercent),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child:  Text('${(progressPercent * 100).toStringAsFixed(2)} % ', style: TextStyle(color: Color(Global.selectedIconColor)),),
                    ),
                  ),
                ),
          ],),
              ],
            );
          });
    } else {
      // Allows user to decide when to start the upload
      return FlatButton.icon(
        textColor: Color(Global.selectedIconColor),
        label: Text('Upload Image', style: TextStyle(fontWeight: FontWeight.bold, color: Color(Global.selectedIconColor))),
        icon: Icon(Icons.arrow_upward_rounded),
        onPressed: _startUpload,
      );
    }
  }

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image", style: TextStyle(color: Color(Global.selectedIconColor))),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: Image.file(File(widget.imageData.imagePath)),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.all(.25),
              decoration: BoxDecoration(
                color: Colors.deepOrange[100],
                //shape: BoxShape.rectangle,
               // borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Color(Global.selectedIconColor),
                  width: 3,
                ),
              ),
              child: Center(
                child: getUploadState(),
              ),
            ),
          ),
          // _compassDataWidget(),
          // _captureControlRowWidget(),
        ],
      ),
    );
  }
}
