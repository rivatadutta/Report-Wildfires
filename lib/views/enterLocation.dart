import 'package:fire_project/views/viewMapOrReport.dart';
import 'package:flutter/material.dart';
import '../globalVariables.dart';

class EnterLocation extends StatefulWidget {
  @override
  _EnterLocationState createState() => _EnterLocationState();
}

class _EnterLocationState extends State<EnterLocation> {
  final formKey = GlobalKey<FormState>();

  String userAddress = Global.userAddress ?? "";

  final address1Controller =
      new TextEditingController(text: Global.userAddress ?? "");

  void _signInAddress() {
    setState(() {
      if (formKey.currentState.validate()) {
        String userAddress = address1Controller.text;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => VeiwMapOrReport(),
            transitionsBuilder: (context, animation1, animation2, child) =>
                FadeTransition(opacity: animation1, child: child),
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(30, 160, 30, 0),
                child: Text('And your location?',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    style: TextStyle(fontSize: 25),
                    validator: (val) {
                      if (val.isEmpty) {
                        return "Please enter an address";
                      }
                      return null;
                    },
                    controller: address1Controller,
                    decoration: InputDecoration(
                      hintText: "address:",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                    ),
                    onChanged: (text) {
                      userAddress = text;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _signInAddress();
        },
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
