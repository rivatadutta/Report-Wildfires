import 'package:fire_project/loginPages/enterLocation.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import'package:fire_project/globalData/globalVariables.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fire_project/services/firebase_auth_service.dart';
import 'package:fire_project/globalData/globalVariables.dart';

Future<void> saveNamePreference(String displayName) async {
  SharedPreferences userNamePrefs = await SharedPreferences.getInstance();
  userNamePrefs.setString("displayName", displayName);
}

// to load shared string
Future<String> getNamePreference() async {
  SharedPreferences userNamePrefs = await SharedPreferences.getInstance();
  String displayName = userNamePrefs.getString("displayName");
  return displayName;
}

class EnterName extends StatefulWidget {
  @override
  _EnterNameState createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {

  final formKey = GlobalKey<FormState>();
  static String displayName;
  String userId;
  StoredUserData _storedUserData;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("Users");


  final userNameController =
      new TextEditingController(text: Global.displayName ?? "");


  Future<void> _signInAnonymously(String displayName) async {
    try {
      // retrieve firebaseAuth from above in the widget tree
      final AuthService auth = Provider.of<AuthService>(context);
      await auth.signInAnonymously();
      //store user on firebase
      User user = await auth.currentUser();
      String userId;
      setState(() {
        userId = user.uid;
      });
      CollectionReference users = Firestore.instance.collection('users');
      users.document(userId).setData({
        'displayName': displayName,
      });
    }
    catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  // Create a CollectionReference called users that references the firestore collection


  void _signInName() {
    setState(() {
      if (formKey.currentState.validate()) {
        _storedUserData = StoredUserData(
          userId: userId,
        );
        String displayName = userNameController.text;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => EnterLocation(userData: _storedUserData),
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
                        TextStyle(fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: .1)),
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
                      displayName = text;
                      FirebaseFunctions.currentUserData["displayName"] = text;
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
          _signInAnonymously(userNameController.text);
          _signInName();
        },
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, color: Color(Global.selectedIconColor)),
      ),
    );
  }
}






