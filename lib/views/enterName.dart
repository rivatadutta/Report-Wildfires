import 'package:fire_project/views/enterLocation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebaseFunctions.dart';
import '../globalVariables.dart';

Future<void> saveNamePreference(String userName) async {
  SharedPreferences userNamePrefs = await SharedPreferences.getInstance();
  userNamePrefs.setString("userName", userName);
}

// to load shared string
Future<String> getNamePreference() async {
  SharedPreferences userNamePrefs = await SharedPreferences.getInstance();
  String userName = userNamePrefs.getString("userName");
  return userName;
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
        String userName = userNameController.text;
        // saveNamePreference(userName).then((_) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => EnterLocation(),
            transitionsBuilder: (context, animation1, animation2, child) =>
                FadeTransition(opacity: animation1, child: child),
            transitionDuration: Duration(milliseconds: 300),
          ),
          // );
          // }
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
                      FirebaseFunctions.currentUserData["userName"] = text;
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
