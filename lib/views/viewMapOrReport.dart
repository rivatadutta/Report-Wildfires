import 'package:fire_project/services/firebase_auth_service.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:fire_project/views/camera.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:flutter/widgets.dart';
import 'package:fire_project/loginPages/enterName.dart';
import 'package:provider/provider.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
void inputData() async {
  final FirebaseUser user = await auth.currentUser();
  final uid = user.uid;
  // here you write the codes to input the data into firestore
}

void username() async {
  final username = await getNamePreference();
}

class ViewMapOrReport extends StatefulWidget {
  @override
  _ViewMapOrReportState createState() => _ViewMapOrReportState();
}

class _ViewMapOrReportState extends State<ViewMapOrReport> {

  Future<void> _signOut() async {
    try {
      final AuthService authLogOut = Provider.of<AuthService>(context, listen: false);
      await authLogOut.signOut();
    }  catch (e) {
     print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color(Global.backgroundColor),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 120, 30, 0),
                  child: Text('Welcome ${FirebaseFunctions.currentUserData["displayName"]}',
                style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                ),
              ),
              Align(
                child: Container(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: Text('What would you like to do today?',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                height: 60,
                width: 200,
                child: RaisedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            MapRender(),
                        transitionsBuilder: (context, animation1, animation2,
                                child) =>
                            FadeTransition(opacity: animation1, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),
                  label: Text(
                    "View Map",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  icon: Icon(Icons.map_outlined),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                height: 60,
                width: 220,
                child: RaisedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            CameraApp(),
                        transitionsBuilder: (context, animation1, animation2,
                                child) =>
                            FadeTransition(opacity: animation1, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),
                    );
                  },
                  color: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),
                  label: Text(
                    "Upload Image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  icon: Icon(Icons.add_a_photo_sharp),
                ),
              ),
              //EDIT UI
              Container(
                margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                height: 60,
                width: 200,
                child: RaisedButton.icon(
                  onPressed: () {
                    _signOut();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            EnterName(),
                        transitionsBuilder: (context, animation1, animation2,
                            child) =>
                            FadeTransition(opacity: animation1, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),
                    );
                  },
                  color: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),
                  label: Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  icon: Icon(Icons.map_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
