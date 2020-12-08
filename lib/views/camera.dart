import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:fire_project/views/confirmAndUpload.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fire_project/globalData/globalVariables.dart';

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(),
    );
  }
}

List<CameraDescription> cameras = [];

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  CompassEvent compassData;
  String videoPath;
  VoidCallback videoPlayerListener;

  bool _hasPermissions = false;
  CompassEvent _lastRead; //Compass Data to be sent to firebase
  DateTime _lastReadAt;
  double _compassVal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      /*appBar: AppBar(
        title: Text("Camera", style: TextStyle(fontSize:20, fontWeight: FontWeight.w300, letterSpacing: .5, color: Color(Global.selectedIconColor))),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),*/
      // body: Center(
      //   child: _buildCompass(),
      // ),
      body: Stack(
        children: <Widget>[
           Container(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            decoration: BoxDecoration(
              color: Color(Global.backgroundColor),
              border: Border.all(
              color: Colors.grey,
              width: 0.00,
            ),
            ),
          ),
          Positioned(
            top: 65,
            right: 8.0,
            child: Container(
              height: 55.0,
              child: Align(
                alignment: Alignment.topLeft,
                child: _buildCompass(),
              )
            ),
          ),
            Align(
            alignment: Alignment.center,
            child: Container(
                child: Image.asset('assets/images/imageGuide.png'),
            )
            ),
          Positioned(
            bottom: 60,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.camera_rounded),
                iconSize: 80,
                splashColor: Colors.black12,
                highlightColor: Colors.orangeAccent[200],
                color: Colors.white,
                onPressed: controller != null &&
                    controller.value.isInitialized &&
                    !controller.value.isRecordingVideo
                    ? onTakePictureButtonPressed
                    : null,
              ),
            ),
          ),
          // _compassDataWidget(),
        ],
      ),
    );
  }

  Widget _compassDataWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
         // Expanded(
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$_lastRead',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    '$_lastReadAt',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
        //  ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Transform.scale(
          scale: controller.value.aspectRatio/deviceRatio,
          child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),),
    );
  }
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double direction = snapshot.data.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(1.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(Global.backgroundColor),
              shape: BoxShape.circle,
              border: Border.all(color: Color((Global.backgroundColor)), width: 2,)
            ),
            child: Transform.rotate(
              angle: ((direction ?? 0) * (math.pi / 180) * -1),
              child: Image.asset('assets/images/compass.jpg'),
            ),
          ),
        );
      },
    );
  }


  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> getHeading() async {
    final CompassEvent tmp = await FlutterCompass.events.first;
    setState(() {
      _compassVal = tmp.heading;
      _lastRead = tmp;
      _lastReadAt = DateTime.now();
    });
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      getCompassData().then((double compassVal){
        getPictureLocation().then((GeoPoint geoPoint){
      if (mounted) {
        setState((){
          setImageData imageData = setImageData(
            imagePath: filePath,
            timeTaken: DateTime.now(),
            compassData: compassVal,
            imagePosition: geoPoint,
          );
          //get image coordinates
          //get elevation
          // Navigator.push(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => ConfirmAndUpload(),
          //     transitionsBuilder: (context, animation1, animation2, child) =>
          //         FadeTransition(opacity: animation1, child: child),
          //     transitionDuration: Duration(milliseconds: 300),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => confirmAndUpload(imageData: imageData),
            ),
          );
      });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
      });
      });
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<double> getCompassData() async {
    await getHeading();
    double compassVal;
    setState(() {
      compassVal = _compassVal;
    });
    return  compassVal;
  }

  Future<GeoPoint> getPictureLocation() async {
    final Position imagePosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    GeoPoint geoPoint;
    setState(() {
      geoPoint = new GeoPoint(imagePosition.latitude, imagePosition.longitude);
    });
    return geoPoint;
  }


  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

@immutable
class setImageData {
  const setImageData({
    @required this.imagePath,
    @required this.compassData,
    @required this.timeTaken,
    @required this.imagePosition,
  });

  final String imagePath;
  final double compassData;
  final DateTime timeTaken;
  final GeoPoint imagePosition;
}

