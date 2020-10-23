import 'package:fire_project/views/imageUpload.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:flutter/material.dart';
import '../globalVariables.dart';

class VeiwMapOrReport extends StatefulWidget {
  @override
  _VeiwMapOrReportState createState() => _VeiwMapOrReportState();
}

class _VeiwMapOrReportState extends State<VeiwMapOrReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(30, 120, 30, 0),
                child: Text('Welcome,',
                    style:
                        TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: Text('What would you like to do today?',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                            ImageUpload(),
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
            ],
          ),
        ),
      ),
    );
  }
}