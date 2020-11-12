import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_project/globalData/globalVariables.dart';
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
import 'package:fire_project/globalData/firebaseFunctions.dart';
import 'package:fire_project/globalData/globalVariables.dart';

class FirebaseFunctions {
  static Map<String, dynamic> currentUserData = {
    "displayName": null,
    "location": null,
  };
}
