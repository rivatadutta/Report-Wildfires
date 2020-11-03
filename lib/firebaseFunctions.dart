import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseFunctions {
  static Map<String, dynamic> currentUserData = {
    "userName": null,
    "userAddress": null,
  };
}