import 'dart:async';
import 'package:camera/camera.dart';
import 'package:fire_project/landingPage.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:fire_project/services/firebase_auth_service.dart';
import 'package:fire_project/views/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'globalData/globalVariables.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new


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
    return Provider<AuthService>(
        create: (_) => FirebaseAuthService(),
        dispose: (_, AuthService authService) => authService.dispose(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: Color(Global.backgroundColor),
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          debugShowCheckedModeBanner: false,
          // home: MapRender(),
          home: LandingPage(),
        ),
    );
  }
}
