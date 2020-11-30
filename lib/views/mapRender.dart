import 'dart:async';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/cupertino.dart';
import 'camera.dart';

class MapRender extends StatefulWidget {
  @override
  _MapRenderState createState() => _MapRenderState();
}

class _MapRenderState extends State<MapRender> {
  String searchAddr;
  GoogleMapController mapController;

  Completer<GoogleMapController> _controller = Completer();

  static LatLng _initialPosition;
  BitmapDescriptor pinLocationIcon; //create custom pin not working yet
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    setCustomMapPin();
  }

  Tuple2<double,double> findIntersection(Tuple2<double,double> location1, Tuple2<double,double> location2, double heading1, double heading2) {
    // We basically perform Gaussian elimination on a 2x2 matrix to solve for variables.
    // Then plug variables into parameterization of eqs.
    //
    // Find where vectors are equal
    // Long1 + sin(head1)X = Long2 + sin(head2)Y
    // Lat1 + cos(head1)X = Lat2 + cos(head2)Y
    // Manipulate and represent as matrix
    // [sin(head1)X - sin(head2)Y | (Long2 - Long1)]
    // [cos(head1)X - cos(head2)Y | (Lat2 - Lat1)]
    var mtx = Matrix3(
        sin(heading1*(pi/180)),
        cos(heading1*(pi/180)),
        0,
        -1*sin(heading2*(pi/180)),
        -1*cos(heading2*(pi/180)),
        0,
        location2.item1 - location1.item1,
        location2.item2 - location1.item2,
        0);

    // Subtract (ratio * Row0) from Row1 in order to cancel out cos(head1)X
    var ratio = mtx.entry(1,0) / mtx.entry(0,0);
    mtx.setEntry(1,0, 0);
    mtx.setEntry(1,1, mtx.entry(1,1) - ratio*mtx.entry(0,1));
    mtx.setEntry(1,2, mtx.entry(1,2) - ratio*mtx.entry(0,2));

    // Divide to find value of Y
    var y = mtx.entry(1,2) / mtx.entry(1,1);

    // Substitute Y into Row0 and solve for X
    var x = (mtx.entry(0,2) - y*mtx.entry(0,1)) / mtx.entry(0,0);
    // print("x:" + x.toString() + "y:" + y.toString());

    // Substitute x into parameter equation to find intersection point
    return Tuple2<double,double>(
        location1.item1 + sin(heading1*(pi/180)) * x,
        location1.item2 + cos(heading1*(pi/180)) * x);
  }

  Tuple2<double,double> averageCoords(List<Tuple2<double,double>> coords){
    double item1Avg = 0;
    double item2Avg = 0;

    for (var i = 0; i < coords.length; i++){
      item1Avg += coords[i].item1;
      item2Avg += coords[i].item2;
    }
    item1Avg = item1Avg / coords.length;
    item2Avg = item2Avg / coords.length;

    return Tuple2<double,double>(item1Avg,item2Avg);
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/icon/icon.png.png');
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      print('${placemark[0].name}');
    });
  }

  Future<void> searchandNavigate() async {
    print(Global.userAddress);
    List<Location> location = await locationFromAddress(searchAddr);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location[0].latitude, location[1].longitude),
        zoom: 10.0)));
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onAddMarkerButtonPressed() {
    // Example of findIntersection and average
    const a = const Tuple2<double,double>(-122.050316, 36.993127);
    const b = const Tuple2<double,double>(-122.053105, 36.970124);
    Tuple2<double,double> inter = findIntersection(a, b, 250, 290);
    List<Tuple2<double,double>> intersectionList = [a, b, inter];
    Tuple2<double,double> avg = averageCoords(intersectionList);
    print("inter:" + inter.toString());
    print("Avg of a, b, inter:" + avg.toString());

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
              title: "fire location",
              snippet: "time, date reported",
              onTap: () {}),
          onTap: () {},
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  Widget mapButton(Function function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(7.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        elevation: 0.0,
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: _initialPosition == null
          ? Container(
              child: Center(
                child: Text(
                  'loading map...',
                  style: TextStyle(
                      fontFamily: 'Avenir-Medium', color: Colors.black),
                ),
              ),
            )
          : Container(
              child: Stack(children: <Widget>[
                GoogleMap(
                  mapType: _currentMapType,
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.0,
                  ),
                  zoomGesturesEnabled: true,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  top: 30.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Enter Address',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
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
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                      child: Column(
                        children: <Widget>[
                          mapButton(
                              _onAddMarkerButtonPressed,
                              Icon(Icons.add_location_alt_rounded),
                              Colors.deepOrange),
                          mapButton(_onMapTypeButtonPressed,
                              Icon(Icons.collections), Colors.green),
                        ],
                      )),
                )
              ]),
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
}

/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoder/geocoder.dart';
import 'camera.dart';

// //Below is a function that gets the users current location, or last known location.
// //The function will return a Position variable
// Future<Position> currentLocation() async {
// //First, I want to check if location services are available
// //Lines below are to check if location services are enabled
//   GeolocationStatus geolocationStatus =
//       await Geolocator().checkGeolocationPermissionStatus();
// //If we get access to the location services, we should get the current location, and return it
//   if (geolocationStatus == GeolocationStatus.granted) {
// //Get the current location and return it
//     Position position = await Geolocator()
//         .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     return position;
//   }
// //Else, if we get any other value, we will return the last known position
//   else {
//     Position position = await Geolocator()
//         .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
//     return position;
//   }
// }

class MapRender extends StatefulWidget {
  @override
  _MapRenderState createState() => _MapRenderState();
}

class _MapRenderState extends State<MapRender> {
  String searchAddr;
  GoogleMapController mapController;

  Completer<GoogleMapController> _controller = Completer();

  // Creating a variable currPosition that will be used to store the users current position
  Position currPosition;
  LatLng currLocation;

  // // Initializing center of map
  // static LatLng _center;

  // //Function used to get users original position
  // Future<void> _getUserLocation() async {
  //   currPosition = await currentLocation();
  //   _center = LatLng(currPosition.latitude, currPosition.longitude);
  //   await FirebaseFunctions.pushUserLocation(
  //       currPosition.latitude, currPosition.longitude);
  // }

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
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.hybrid,
            onMapCreated: onMapCreated,
            // initialCameraPosition: CameraPosition(
            //   target: _center,
            //   zoom: 14.0,
            // ),
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
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 130.0, 16.0, 16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
//Adding another floating button to mark locations
                  FloatingActionButton(
                    heroTag: 'setLocationTag',
                    // onPressed: _onAddMarkerButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(
                      Icons.add_location,
                      size: 36.0,
                    ),
                  ),
                  // confirmFinalPosition(),
                ],
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
    print(Global.userAddress);
    List<Location> location = await locationFromAddress(searchAddr);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location[0].latitude, location[1].longitude),
        zoom: 10.0)));
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
*/
