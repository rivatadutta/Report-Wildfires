import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fire_project/landingPage.dart';
import 'package:fire_project/views/camera.dart';
import 'package:flutter/material.dart';

import 'globalData/globalVariables.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(Global.backgroundColor),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // home: MapRender(),
      home: LandingPage(),
    );
  }
}
