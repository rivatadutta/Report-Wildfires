import 'package:flutter/material.dart';

class MapRender extends StatefulWidget {
  @override
  _MapRenderState createState() => _MapRenderState();
}

class _MapRenderState extends State<MapRender> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Image(
          image: AssetImage('assets/images/map.jpg'),
        ),
      ),
    );
  }
}
