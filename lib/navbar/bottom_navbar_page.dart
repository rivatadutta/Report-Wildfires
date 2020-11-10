import 'package:fire_project/navbar/bottom_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fire_project/globalData/globalVariables.dart';

class TabsPage extends StatefulWidget {
  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          for (final tabItem in TabNavigationItem.items) tabItem.page,
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        backgroundColor: Color(Global.backgroundColor),
        iconSize: 30,
        unselectedItemColor: Color(Global.iconColor),
        selectedItemColor: Color(Global.selectedIconColor),
        unselectedFontSize: 10,
        selectedFontSize: 15,
        unselectedIconTheme: IconThemeData(
          color: Color(Global.iconColor),
          opacity: 1.0,
          size: 30
        ),
        selectedIconTheme: IconThemeData(
            color: Color(Global.selectedIconColor),
            opacity: 1.0,
            size: 35
        ),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          for (final tabItem in TabNavigationItem.items)
            BottomNavigationBarItem(
              icon: tabItem.icon,
              title: tabItem.title,
            ),
        ],
      ),
    );
  }
}
