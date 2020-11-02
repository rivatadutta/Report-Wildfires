import 'dart:io';
import 'dart:async';

import 'package:fire_project/views/enterName.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:fire_project/views/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'globalVariables.dart';

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
      home: EnterName(),
    );
  }
}