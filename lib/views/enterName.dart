import 'package:flutter/material.dart';

import '../globalVariables.dart';
import 'imageUpload.dart';

class EnterName extends StatefulWidget {
  @override
  _EnterNameState createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {
  final formKey = GlobalKey<FormState>();

  String userName = Global.userName ?? "";

  final userNameController =
      new TextEditingController(text: Global.userName ?? "");

  void _signIn() {
    setState(() {
      if (formKey.currentState.validate()) {
        String userName = userNameController.text;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ImageUpload(),
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
          _signIn();
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
