import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/views/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

<<<<<<< HEAD
import 'package:fire_project/globalData/globalVariables.dart';
=======
import '../globalData/globalVariables.dart';
>>>>>>> 7e664a95e3694538e76dff25da39a39e42ecf988

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class confirmAndUpload extends StatelessWidget {
  final String imagePath;

  const confirmAndUpload({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera"),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: Image.file(File(imagePath)),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Colors.grey,
                width: 3.0,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.cancel_outlined),
              iconSize: 40,
              color: Colors.blue,
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
          Positioned(
            bottom: 30,
            left: 30,
            child: IconButton(
              icon: const Icon(Icons.check_circle_outlined),
              iconSize: 40,
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        Uploader(file: File(imagePath)),
                    transitionsBuilder:
                        (context, animation1, animation2, child) =>
                            FadeTransition(opacity: animation1, child: child),
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
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
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://fire-reporting-88f03.appspot.com');

  StorageUploadTask _uploadTask;

  /// Starts an upload task
  void _startUpload() {
    /// Unique file name for the file
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  Widget getUploadState() {
    if (_uploadTask != null) {
      /// Manage the task state and event subscription with a StreamBuilder
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
              children: [
                if (_uploadTask.isComplete) Text('Image Uploaded'),
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
                LinearProgressIndicator(value: progressPercent),
                Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
              ],
            );
          });
    } else {
      // Allows user to decide when to start the upload
      return FlatButton.icon(
        label: Text('Upload'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: SafeArea(
    child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: Image.file(widget.file),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
            Container(
              child: Center(
                child: getUploadState(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
