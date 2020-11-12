import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'camera.dart';

class MapRender extends StatefulWidget {
  @override
  _MapRenderState createState() => _MapRenderState();
}

class _MapRenderState extends State<MapRender> {
  String searchAddr;
  GoogleMapController mapController;


  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body:  Stack(
        children: <Widget>[
          GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: onMapCreated,
       // options: GoogleMapOptions(
          initialCameraPosition: _kGooglePlex,
    ),
        //initialCameraPosition: _kGooglePlex,
        //onMapCreated: (GoogleMapController controller) {
        //  _controller.complete(controller);
       // },
    //  ),
    Positioned(
          top: 30.0,
          right: 15.0,
          left: 15.0,
          child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          child: TextField(
          decoration: InputDecoration(
          hintText: 'Enter Address',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
          suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: searchandNavigate,
          iconSize: 30.0)),
          onChanged: (val) {
          setState(() {
          searchAddr = val;
        });
        },
        ),
        ),
        ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => CameraApp(),
              transitionsBuilder: (context, animation1, animation2, child) =>
                  FadeTransition(opacity: animation1, child: child),
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        },
        backgroundColor: Colors.deepOrange,
        label: Text('Upload Image'),
        icon: Icon(Icons.add_a_photo_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Future<void> searchandNavigate() async {
    List<Location> location = await locationFromAddress(searchAddr);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(location[0].latitude, location[1].longitude),
        zoom: 10.0)));
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
