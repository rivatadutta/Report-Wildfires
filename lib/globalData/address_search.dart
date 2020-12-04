import 'package:fire_project/globalData/globalVariables.dart';
import 'package:flutter/material.dart';
import 'package:fire_project/globalData/place_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }
  final sessionToken;
  PlaceApiProvider apiClient;
  Suggestion firstItem;
  List<Suggestion> results;

  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: IconButton(
          tooltip: 'Clear',
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      )
    ];
  }

 @override
  Widget buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: IconButton(
        tooltip: 'Back',
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query != '' && firstItem != null) {
      return Scaffold(
        backgroundColor: Color(Global.backgroundColor),
        body: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title:
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text((results[index]).description),
            ),
            onTap: () {
              close(context, results[index]);
            },
          ),
          itemCount: results.length,
        ),
      );
    } else {
      query = '';
      return Scaffold(
        backgroundColor: Color(Global.backgroundColor),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 128.0),
              child: Center(child: Text("Oops! We couldn't find that one.\nTry again.", )),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Global.backgroundColor),
      body: FutureBuilder(
          future: query == ''
              ? null
              : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length != 0) {
                firstItem = snapshot.data[0] as Suggestion;
                results = snapshot.data;
              } else {
                firstItem = null;
                return Scaffold(
                  backgroundColor: Color(Global.backgroundColor),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 128.0),
                        child: Center(child: Text("Oops! We couldn't find that one.\nTry again.", )),
                      )
                    ],
                  ),
                );
              }
            }
            return query == ''
                ? Container(
            )
                : snapshot.hasData
                ? ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title:
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text((snapshot.data[index] as Suggestion).description),
                ),
                onTap: () {
                  close(context, snapshot.data[index] as Suggestion);
                },
              ),
              itemCount: snapshot.data.length,
            )
                : Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 16.0),
              child: Container(child: Text('Loading...')),
            );
          }
      ),
    );
  }
}
