import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:fire_project/services/firebase_auth_service.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:fire_project/views/camera.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '';
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
  String displayName;

  Future<void> _signOut() async {
    try {
      final AuthService authLogOut =
          Provider.of<AuthService>(context, listen: false);
      await authLogOut.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future <String> _getName() async{
    FirebaseUser user = await auth.currentUser();
    DocumentReference userReference = Firestore.instance.collection("users").document(user.uid);
    DocumentSnapshot userDocRef = await userReference.get();
    String name = userDocRef.data["displayName"];
    return name;
  }


  @override
  void initState() {
    super.initState();
    _getName().then((String Name){
      setState((){
        displayName = Name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var fontWeight;
    return Scaffold(
      appBar: AppBar(

        title: Text("Home",style: TextStyle(fontSize:22, fontWeight: FontWeight.w300, letterSpacing: .5, color: Colors.redAccent[700])),
        backgroundColor: Color(Global.backgroundColor),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
              child:Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                height: 25,
                width: 100,
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
                  color: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),
                  label: Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10),
                  ),
                  icon: Icon(Icons.login_outlined, size: 12.0, color: Colors.black54,),
                ),),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
                  child: Text(
                      'Welcome ${displayName}',
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 24, letterSpacing: .65, color: Colors.black87)),
                ),
              ),
              Align(
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: Text('What would you like to do today?',
                      style:
                          TextStyle( fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: .65, color: Colors.black87)),
                ),
              ),
              Align(
                  alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                width: .80*(MediaQuery.of(context).size.width),
                height: .20*(MediaQuery.of(context).size.height),
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
                  color: Colors.deepOrangeAccent[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),

                      label: Padding(
                        padding: EdgeInsets.only(left:0, top: 0, right: 15, bottom: 0),
                       // child: Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        text: TextSpan(
                          text: "View Map",
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 23, letterSpacing: 1.2, color:Colors.brown[900]),
                          children: <TextSpan>[
                            TextSpan(
                            text: '\nof Reported Fires', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 1.2, color:Colors.brown[900])),

                        ],
                      ),
                    ),
                      //),
                        ),
                      icon: Padding(
                        padding:EdgeInsets.only(left:15, top: 0, right: 0, bottom: 0) ,
                      child: Icon(Icons.map_outlined, size: 65.0, color:Colors.deepOrange[900], textDirection: TextDirection.ltr,),
                ),
                  ),
                  ),
              ),

              Align(
                alignment: Alignment.center,
                child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                width: .80*(MediaQuery.of(context).size.width),
                height: .20*(MediaQuery.of(context).size.height),
                child: RaisedButton.icon(
                    padding: EdgeInsets.zero,
                  onPressed: () {
                    int _currentIndex = 2;
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
                  color: Colors.deepOrangeAccent[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    //side: BorderSide(color: Colors.grey),
                  ),
                  elevation: 5,
                  label: Padding(
                    padding: EdgeInsets.only(left:0, top: 0, right: 25, bottom: 0),
                    //child: Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      text: TextSpan(
                        text: "Upload Image",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22, letterSpacing: 1.2, color:Colors.brown[900]),
                        children: <TextSpan>[
                          TextSpan(
                              text: '\nof Fire', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 1.2, color:Colors.brown[900])),

                        ],
                      ),
                    ),
                  ),
                  icon: Padding(
                    padding: EdgeInsets.only(left:15, top: 0, right: 0, bottom: 0),
                    child: Icon(Icons.local_fire_department, size: 65.0, color:Colors.redAccent[700]),
                  ),
                ),
              ),
              ),
              //EDIT UI
            ],
          ),
        ),
      ),
    );
  }
}



