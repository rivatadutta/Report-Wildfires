import 'package:fire_project/loginPages/enterLocation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/Rivata/Desktop/Fire-Reporting/lib/globalData/firebaseFunctions.dart';
import'package:fire_project/globalData/globalVariables.dart';

Future<void> _signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print(e); // TODO: show dialog with error
  }
}

class EnterName extends StatefulWidget {
  @override
  _EnterNameState createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {

  final formKey = GlobalKey<FormState>();

  String userName = Global.userName ?? "";

  final userNameController =
      new TextEditingController(text: Global.userName ?? "");

  void _signInName() {
    setState(() {
      if (formKey.currentState.validate()) {
        userName = userNameController.text;;
        _signInAnonymously();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => EnterLocation(),
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
                child: Text('What is your preferred name?',
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
                        return "Please enter a name";
                      }
                      return null;
                    },
                    controller: userNameController,
                    decoration: InputDecoration(
                      hintText: "NICKNAME:",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                    ),
                    onChanged: (text) {
                      userName = text;
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
          _signInName();
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
