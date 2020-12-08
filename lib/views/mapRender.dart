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
      if ( imageDocRef.data['compassData'] !=null) {
        Tuple2<String, double> compassDirection = _findImageFacingDirection(
            imageDocRef.data['compassData'].toDouble());


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
              title: "Fire Reported at " +
                  formatDate(dateTimeTaken, [HH, ':', nn]) + " on " +
                  formatDate(dateTimeTaken, [dd, '/', mm]),
              snippet: "Click for Details",
              onTap: () {
                showModalBottomSheet<void>(
                  context: context, builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 217, 179, .4),
                      // gradient: LinearGradient(colors: [Color(Global.backgroundColor), Color.fromRGBO(255, 217, 179, .4)],begin: Alignment.topCenter,
                      // end: Alignment.bottomCenter,),
                      //backgroundBlendMode: BlendMode.
                      border: Border(top: BorderSide(
                          width: .7, color: Color(Global.selectedIconColor))),
                    ),
                    height: 400,
                    //color: Color.fromRGBO(255, 217, 179, .4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(children: [
                            Padding(padding: const EdgeInsets.all(10.0)),
                            Container(
                              width: 160,
                              height: 320,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(imageUrl),
                                ),),),
                            Padding(padding: const EdgeInsets.fromLTRB(
                                4.0, 0.0, 4.0, 0.0)),
                            Center(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    1.0, 10.0, 2.0, 10.0),
                                width: 160,
                                decoration:
                                BoxDecoration(boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    offset: Offset.zero,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ],),
                                //child: Padding(padding: const EdgeInsets.all(0.25),
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(text: "\nTaken at\n",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        letterSpacing: 1.2,
                                        color: Colors.brown[900]),
                                    children: <TextSpan>[
                                      TextSpan(text: formatDate(
                                          dateTimeTaken, [HH, ':', nn]),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              color: Color(
                                                  Global.selectedIconColor))),
                                      TextSpan(text: "\non "),
                                      TextSpan(text: formatDate(dateTimeTaken,
                                          [dd, '/', mm, '/', yyyy]),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              color: Color(
                                                  Global.selectedIconColor))),
                                      TextSpan(text: "\n\nImage Direction: \n"),
                                      TextSpan(text: compassDirection.item1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 19,
                                              letterSpacing: 1.2,
                                              color: Color(
                                                  Global.selectedIconColor))),
                                      TextSpan(text: " Compass Reading of " +
                                          compassDirection.item2
                                              .toStringAsFixed(
                                              2).toString() +
                                          "°"),
                                      TextSpan(
                                          text: "\n\nImage Coordinates: \n"),
                                      TextSpan(text: imageDocRef
                                          .data['imagePosition'].latitude
                                          .toStringAsFixed(5) + "\n" +
                                          imageDocRef.data['imagePosition']
                                              .longitude.toStringAsFixed(
                                              5),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 19,
                                              letterSpacing: 1.2,
                                              color: Colors.brown[900])),
                                      TextSpan(text: "\n\n" +
                                          placeMark.locality.toString() + "," +
                                          placeMark.country.toString() + "," +
                                          placeMark.postalCode.toString(),
                                          style: TextStyle(color: Color(
                                              Global.selectedIconColor))),
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

        double p1Endlat = imageDocRef.data['imagePosition'].latitude +
            cos(radians(imageDocRef.data['compassData'] + 90.0));
        double p1Endlong = imageDocRef.data['imagePosition'].longitude +
            sin(radians(imageDocRef.data['compassData'] + 90.0));
        //  print("P1Start: " + imageDocRef.data['imagePosition'].latitude.toString() + "," +imageDocRef.data['imagePosition'].longitude.toString());
        //print("P2END: " + p1Endlat.toString() + "," + p1Endlong.toString());
        double polyLineLatDirection = sin(
            radians(imageDocRef.data['compassData'] + 90.0)) / 20;
        double polyLineLongDirection = -cos(
            radians(imageDocRef.data['compassData'] + 90.0)) / 20;
        //print("compass reading:" +imageDocRef.data['compassData'].toString());
        //print("actual direction:" +(imageDocRef.data['compassData']+90).toString());
        //print("compass lat:" + polyLineLatDirection.toString());
        //print("compass long:" + polyLineLatDirection.toString());
        polylineList.add(
            Polyline(
                polylineId: PolylineId(markerId.toString()),
                visible: true,
                color: Colors.blueAccent,
                width: 2,
                patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
                points: [
                  LatLng(imageDocRef.data['imagePosition'].latitude,
                      imageDocRef.data['imagePosition'].longitude),
                  LatLng(imageDocRef.data['imagePosition'].latitude +
                      polyLineLatDirection,
                      polyLineLongDirection +
                          imageDocRef.data['imagePosition'].longitude)
                ]
            )
        );
      }
      markerId++;
    }

    double imageHeading1;
    double imageHeading2;
    Tuple2<double, double> a;
    Tuple2<double, double> b;
    Tuple2<double, double> intersection;
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
          if (imageDocRef1.data['compassData'] !=null && imageDocRef2.data['compassData'] !=null){
          imageHeading1 = imageDocRef1.data['compassData'].toDouble();
          imageHeading2 = imageDocRef2.data['compassData'].toDouble();
          a = Tuple2<double, double>(
              imageDocRef1.data['imagePosition'].latitude,
              imageDocRef1.data['imagePosition'].longitude);
          b = Tuple2<double, double>(
              imageDocRef2.data['imagePosition'].latitude,
              imageDocRef2.data['imagePosition'].longitude);
          //if distance bewteen points is not greater than 100 miles
          if (!(Geolocator.distanceBetween(a.item1, a.item2, b.item1, b.item2) > 160934)){
          intersection = findIntersection(a, b, imageHeading1, imageHeading2);
          print("A: " + a.toString() + "B: " + b.toString());
          print(intersection.toString());
          if ((intersection.item1 != 0.0) && (intersection.item2 != 0.0)) {
          intersectionList.add(
          intersection); //list of all intersection`s between all images
          }
          }
          }
        }
      }
    }
    //print("intersections: " + intersectionList.toString());
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
            title: "Fire",
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
      if(mounted) {
        setState(() {
          markers = markersAndLines.item1;
          polylines = markersAndLines.item2;
        });
      }});
  }


  bool DoesRaysIntersects(Point p1, Point p2, Point n1, Point n2) {
    double u = (p1.y * n2.x + n2.y * p2.x - p2.y * n2.x - n2.y * p1.x) /
        (n1.x * n2.y - n1.y * n2.x);
    double v = (p1.x + n1.x * u - p2.x) / n2.x;

    return u > 0 && v > 0;
  }

  Point GetPointOfIntersection(Point p1, Point p2, Point n1, Point n2) {
    Point p1End = p1 + n1; // another point in line p1->n1
    Point p2End = p2 + n2; // another point in line p2->n2

    double m1 = (p1End.y - p1.y) / (p1End.x - p1.x); // slope of line p1->n1
    double m2 = (p2End.y - p2.y) / (p2End.x - p2.x); // slope of line p2->n2

    double b1 = p1.y - m1 * p1.x; // y-intercept of line p1->n1
    double b2 = p2.y - m2 * p2.x; // y-intercept of line p2->n2

    double px = (b2 - b1) / (m1 - m2); // collision x
    double py = m1 * px + b1; // collision y
    return new Point(px, py); // return statement
  }

  Tuple2<double, double> findIntersection(Tuple2<double, double> location1,
      Tuple2<double, double> location2, double heading1, double heading2) {
    Point p1 = Point(location1.item2, location1.item1);
    Point d1 = Point((-cos(radians(heading1 + 90.0)) / 20),
        sin(radians(heading1 + 90.0)) / 20);
    Point p2 = Point(location2.item2, location2.item1);
    Point d2 = Point((-cos(radians(heading2 + 90.0)) / 20),
        sin(radians(heading2 + 90.0)) / 20);

    if (DoesRaysIntersects(p1, p2, d1, d2) == true) {
      Point intersectionPoint = GetPointOfIntersection(p1, p2, d1, d2);
      return Tuple2<double, double>(intersectionPoint.y, intersectionPoint.x);
    }

    return Tuple2<double, double>(0.0, 0.0);
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

  Tuple2<String, double> _findImageFacingDirection(double compassData) {
    if ((compassData >= 337.5 && compassData <= 360.0) ||
        (compassData >= 0.0 && compassData < 22.5)) {
      return Tuple2<String, double>("North", compassData);
    }
    else if ((compassData >= 22.5 && compassData <= 67.5)) {
      return Tuple2<String, double>("NorthEast", compassData);
    }
    else if ((compassData >= 67.5 && compassData <= 112.5)) {
      return Tuple2<String, double>("East", compassData);
    }
    else if (compassData >= 112.5 && compassData <= 157.5) {
      return Tuple2<String, double>("SouthEast", compassData);
    }
    else if (compassData >= 157.5 && compassData <= 202.5) {
      return Tuple2<String, double>("South", compassData);
    }
    else if (compassData >= 202.5 && compassData <= 247.5) {
      return Tuple2<String, double>("SouthWest", compassData);
    }
    else if (compassData >= 247.5 && compassData <= 292.5) {
      return Tuple2<String, double>("West", compassData);
    }
    else if (compassData >= 292.5 && compassData <= 337.5) {
      return Tuple2<String, double>("NorthWest", compassData);
    }
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
    top: 50.0,
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
    margin: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
    child:
    mapButton(_onMapTypeButtonPressed,
    Icon(Icons.collections), Colors.green),
    ),
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