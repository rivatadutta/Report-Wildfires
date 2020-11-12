import 'package:fire_project/loginPages/enterName.dart';
import 'package:fire_project/navbar/bottom_navbar_page.dart';
import 'package:fire_project/views/viewMapOrReport.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // retrieve firebaseAuth from above in the widget tree
    final AuthService auth = Provider.of<AuthService>(context);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (_, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user == null) {
            return EnterName();
          }
          return TabsPage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
