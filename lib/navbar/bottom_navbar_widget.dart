import 'package:fire_project/views/camera.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:fire_project/views/viewMapOrReport.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class TabNavigationItem {
  final Widget page;
  final Widget title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: ViewMapOrReport(),
          icon: Icon
            (Icons.home,),
          title: Text("Home"),
        ),
        TabNavigationItem(
          page: CameraApp(),
          icon: Icon(Icons.add_a_photo,),
          title: Text("Take Photo"),
        ),
        TabNavigationItem(
          page: MapRender(),
          icon: Icon(Icons.map,),
          title: Text("View Map"),
        ),
      ];
}
