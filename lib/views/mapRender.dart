import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/globalData/place_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:tuple/tuple.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/cupertino.dart';
import 'camera.dart';
import 'package:fire_project/globalData/address_search.dart';
import 'package:uuid/uuid.dart';

class PinInformation {
  Image image;
  LatLng location;
  DateTime timeTaken;
  PinInformation({
    this.image,
    this.location,
    this.timeTaken,
  });}

class MapRender extends StatefulWidget {
  @override
  _MapRenderState createState() => _MapRenderState();
}

class _MapRenderState extends State<MapRender> {

  String searchAddr;
  String _streetNumber = '';
  String _street= '';
  String _city = '';
  String _zipCode = '';
  GoogleMapController mapController;
  final addressSearchcontroller = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();

  static LatLng _initialPosition;
  BitmapDescriptor pinLocationIcon; //create custom pin not working yet
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;


  List<Marker> markers = [];
  List<Polyline> polylines = [];
  List<Tuple2<double, double>> intersectionList = [];

  Future<Tuple2<List<Marker>,List<Polyline>>> _createMarkersForUserImagesandFires() async {
    List<Marker> markersList = [];
    List<Polyline> polylineList = [];
    List<DocumentSnapshot> imageDocumentsList = [];
    int markerId = 0;


    //create list of all image document ids
    QuerySnapshot querySnapshot = await Firestore.instance.collection("images")
        .getDocuments();
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      var a = querySnapshot.documents[i];
      print(a);
      imageDocumentsList.add(a);
    }
    //iterate through all images uploaded to firebase
    for (DocumentSnapshot document in imageDocumentsList) {
      // ignore: deprecated_member_use
      String documentId = document.documentID;
      DocumentReference imageReference = Firestore.instance.collection("images")
          .document(documentId);
      DocumentSnapshot imageDocRef = await imageReference.get();

      String imageUrl = imageDocRef.data["url"];
      DateTime dateTimeTaken = imageDocRef.data["timeTaken"].toDate();
      List<Placemark> placemarks = await placemarkFromCoordinates(imageDocRef.data['imagePosition'].latitude,
          imageDocRef.data['imagePosition'].longitude);
      Placemark placeMark  =  placemarks[0];



      markersList.add(Marker(
          markerId: MarkerId(markerId.toString()),
          position: LatLng(imageDocRef.data['imagePosition'].latitude,
              imageDocRef.data['imagePosition'].longitude),
          onTap: () =>
          [_changeMap(LatLng(
              imageDocRef.data['imagePosition'].latitude,
              imageDocRef.data['imagePosition'].longitude)),
            _showMarkerImage(imageUrl),
          ],

          infoWindow: InfoWindow(
            title: "Reported Fire",
            snippet: "Tap for Info",
            onTap: (){
              showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                     color:  Color.fromRGBO(255, 217, 179, .4),
                   // gradient: LinearGradient(colors: [Color(Global.backgroundColor), Color.fromRGBO(255, 217, 179, .4)],begin: Alignment.topCenter,
                     // end: Alignment.bottomCenter,),
                    //backgroundBlendMode: BlendMode.
                    border: Border(top: BorderSide(width: .7, color: Color(Global.selectedIconColor))),
                  ),
                  height: 400,
                  //color: Color.fromRGBO(255, 217, 179, .4),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row( children: [
                          Padding(padding: const EdgeInsets.all(10.0)),
                          Container(
                            width: 160,
                            height: 320,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(imageUrl),
                              ),),),
                          Padding(padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0)),
                          Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(1.0, 10.0, 2.0, 10.0),
                              width: 160,
                              decoration:
                              BoxDecoration(boxShadow: <BoxShadow>[
                                BoxShadow(
                                  blurRadius: 4.0,
                                  offset: Offset.zero,
                                  color: Colors.white.withOpacity(0.4),
                                ),],),
                              //child: Padding(padding: const EdgeInsets.all(0.25),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(text: "\nTaken at\n", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,letterSpacing: 1.2,color: Colors.brown[900]),
                                  children: <TextSpan>[
                                    TextSpan(text:formatDate(dateTimeTaken, [HH, ':', nn]),
                                        style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20,letterSpacing: 1.2,color: Color(Global.selectedIconColor))),
                                    TextSpan(text: "\non "),
                                    TextSpan(text:formatDate(dateTimeTaken, [dd, '/', mm, '/', yyyy]),
                                        style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20,letterSpacing: 1.2,color: Color(Global.selectedIconColor))),
                            TextSpan(text: "\n\nCompass Reading: "),
                                    TextSpan(text: imageDocRef.data['compassData'].round().toString() + "°", style: TextStyle(
                                        fontWeight: FontWeight.w400, fontSize: 19,letterSpacing: 1.2,color: Colors.brown[900])),
                                    TextSpan(text: "\n\nCoordinates: \n"),
                                    TextSpan(text: imageDocRef.data['imagePosition'].latitude.toString() +"\n" + imageDocRef.data['imagePosition'].longitude.toString(),
                                        style: TextStyle(fontWeight: FontWeight.w400,fontSize: 19,letterSpacing: 1.2,color: Colors.brown[900])),
                                    TextSpan(text: "\n\n"+ placeMark.locality.toString() +"," + placeMark.country.toString()+"," +
                                        placeMark.postalCode.toString()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        ),
                IconButton(
                icon: const Icon(Icons.expand_more),
                iconSize: 40,
                color: Color(Global.selectedIconColor),
                padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                onPressed: () => Navigator.pop(context),
                ),
                      ],
                    ),
                  ),
                );
              },
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow)),
      );

      polylineList.add(
          Polyline(
              polylineId: PolylineId(markerId.toString()),
              visible: true,
              color: Colors.blueAccent,
              width: 2,
              patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
              points: [LatLng(imageDocRef.data['imagePosition'].latitude,imageDocRef.data['imagePosition'].longitude),
                LatLng(imageDocRef.data['imagePosition'].latitude + cos(imageDocRef.data['compassData']*(pi/180))/20,
                    imageDocRef.data['imagePosition'].longitude + sin(imageDocRef.data['compassData']*(pi/180))/20)]
          )
      );

      markerId++;
    }

    double imageHeading1;
    double imageHeading2;

    Tuple2<double,double> a;
    Tuple2<double,double> b;
    Tuple2<double,double> intersection;

    //iterat
    //call intersection
    for (DocumentSnapshot image1 in imageDocumentsList) {
      DocumentReference imageReference1 = Firestore.instance.collection(
          "images").document(image1.documentID);
      DocumentSnapshot imageDocRef1 = await imageReference1.get();
      for (DocumentSnapshot image2 in imageDocumentsList) {
        DocumentReference imageReference2 = Firestore.instance.collection(
            "images").document(image2.documentID);
        DocumentSnapshot imageDocRef2 = await imageReference2.get();
        //Don't look at the same points.
        if (image1 == image2) {
          continue;
        }
        else {
          imageHeading1 = imageDocRef1.data['compassData'].toDouble();
          imageHeading2 = imageDocRef2.data['compassData'].toDouble();
          a = Tuple2<double, double>(
              imageDocRef1.data['imagePosition'].latitude,
              imageDocRef1.data['imagePosition'].longitude);
          b = Tuple2<double, double>(
              imageDocRef2.data['imagePosition'].latitude,
              imageDocRef1.data['imagePosition'].longitude);
          intersection = findIntersection(a, b, imageHeading1, imageHeading2);
          print("A: " + a.toString() + "B: " + b.toString());
          print(intersection.toString());
          intersectionList.add(
              intersection); //list of all intersection`s between all images
        }
      }
    }
    print("intersections: " + intersectionList.toString());
    //
    // //Messing around with seeing intersections that are similar
    // for (Tuple2 fireMarkers1 in intersectionList) {
    //   for (Tuple2 fireMarkers2 in intersectionList) {
    //     if (fireMarkers1 == fireMarkers2) {
    //       continue;
    //     }
    //     //calculate distance between two intersection points
    //     var _distanceInMeters = Geolocator.distanceBetween(
    //       fireMarkers1.item1,
    //       fireMarkers1.item2,
    //       fireMarkers2.item1,
    //       fireMarkers2.item2,
    //     );
    //     //if intersection point distances are > than 3 miles, then it is unique intersection point
    //     if (_distanceInMeters > 200) {
    //       if (!uniqueIntersectionMarkers.contains(fireMarkers1)) {
    //         uniqueIntersectionMarkers.add(fireMarkers1);
    //       }
    //       if (!uniqueIntersectionMarkers.contains(fireMarkers2)) {
    //         uniqueIntersectionMarkers.add(fireMarkers2);
    //       }
    //     }
    //     // else {}
    //   }
    // }
    //
    for (Tuple2<double, double> fireMarkers in intersectionList) {
      markersList.add(Marker(
          markerId: MarkerId(markerId.toString()),
          position: LatLng(fireMarkers.item1, fireMarkers.item2),
          onTap: () =>
              _changeMap(LatLng(
                  fireMarkers.item1, fireMarkers.item2)),
          infoWindow: InfoWindow(
            title: "fire",
            snippet: null,),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed)),
      );
      markerId++;
    }

    return Future.value(Tuple2(markersList, polylineList));
  }



  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _createMarkersForUserImagesandFires().then((Tuple2<List<Marker>,List<Polyline>> markersAndLines){
      setState((){
        markers = markersAndLines.item1;
        polylines = markersAndLines.item2;
      });
    });
  }


  Tuple2<double,double> findIntersection(Tuple2<double,double> location1, Tuple2<double,double> location2, double heading1, double heading2) {
    // We basically perform Gaussian elimination on a 2x3 matrix to solve for variables.
    // Then plug variables into parameterization of eqs.
    //
    // Find where vectors are equal
    // Lat1 + cos(head1)X = Lat2 + cos(head2)Y
    // Long1 + sin(head1)X = Long2 + sin(head2)Y
    // Manipulate and represent as matrix
    // [sin(head1)X - sin(head2)Y | (Long2 - Long1)]
    // [cos(head2)X - cos(head2)Y | (Lat2 - Lat1)]
    var mtx = Matrix3(
        sin(heading1*(pi/180)),
        sin(heading2*(pi/180)),
        0,
        -1*cos(heading1*(pi/180)),
        -1*cos(heading2*(pi/180)),
        0,
        //item1 = lat, item2 = long
        location1.item2 - location1.item1,
        location2.item2 - location2.item1,
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
    print("x:" + x.toString() + "y:" + y.toString());

    // Substitute x into parameter equation to find intersection point
    return Tuple2<double,double>(
        location1.item1 + cos(heading1*(pi/180)) * x.abs(),
        location1.item2 + sin(heading1*(pi/180)) * x.abs());
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
    // _findIntersectionMarkers();
    // Example of findIntersection and average
    const a = const Tuple2<double,double>(36.993127, -122.050316);
    const b = const Tuple2<double,double>(36.970124 , -122.053105);
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

  Widget _showMarkerImage(String imageUrl) {
    // String print = position.toString();
    return Row(
      children:[
        Positioned(
          bottom:50,
          child: Container(
            width:100,
            height: 100,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: NetworkImage(imageUrl)
                  //NetworkImage(imageUrl, )),
                )
              // child: Text("${print}")),
            ),
          ),
        ),
      ],
    );
  }
  @override
  void dispose(){
    addressSearchcontroller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text("Map",style: TextStyle(fontSize:20, fontWeight: FontWeight.w300, letterSpacing: .5, color: Colors.redAccent[700])),
        elevation: 2.0,
        backgroundColor: Color(Global.backgroundColor),
      ),*/
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
        child: Stack
          (children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            markers: markers.toSet(),
            polylines: polylines.toSet(),
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
                controller: addressSearchcontroller,
                readOnly: true,
                onTap:() async {
                  final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(context: context, delegate: AddressSearch(sessionToken),);
                  if (result != null)
                  {
                    setState(() {
                      addressSearchcontroller.text = result.description;
                      /* _streetNumber = placeDeatils.streetNumber;
                    _street = placeDeatils.street;
                    _city = placeDeatils.city;
                    _zipCode= placeDeatils.zipCode;*/

                    });}
                },
                decoration: InputDecoration(
                    hintText: 'Search Location',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(left: 15.0, top: 15.0),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Color(Global.selectedIconColor)),
                        onPressed:searchandNavigate,
                        iconSize: 30.0)),
                onChanged: (val) {
                  setState(() {
                    //addressSearchcontroller.text = result.description;
                    searchAddr = val;
                  });
                },
              ),
              // Text('Stret Number': $_streetNumber),
              //Text('City': $_city),
              //Text('Stret Number': $_streetNumber),
              //Text('Stret Number': $_streetNumber),

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _changeMap(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(position.latitude, position.longitude),
        zoom: 19.4,
      ),
    ));


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