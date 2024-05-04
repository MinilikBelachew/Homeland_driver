import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:driver/assistant/request_assistant.dart';
import 'package:driver/config_maps.dart';

import 'package:driver/main.dart';

import 'package:driver/data_handler/app_data.dart';
import 'package:driver/models/address.dart';
import 'package:driver/models/all_user.dart';
import 'package:driver/models/direction_detail.dart';
import 'dart:math';

class AssistantMethods {
  // static Future<String> searchCoordinateAddress(Position position,
  //     context) async {
  //   String placeAddress = "";
  //   String st1, st2, st3, st4;
  //   String url =
  //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
  //       .latitude},${position.longitude}&key=$mapkey";
  //
  //   var response = await RequestAssistant.getRequest(url);
  //   if (response != "faild") {
  //     placeAddress = response["results"][0]["formatted_address"];
  //
  //     placeAddress = response["results"][0]["formatted_address"];
  //     Address userPickUpAddress = new Address();
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.placeName = placeAddress;
  //
  //     // st1=response["results"][0]["address_components"][0]["long_name"];
  //     // st2=response["results"][0]["address_components"][1]["long_name"];
  //     // st3=response["results"][0]["address_components"][5]["long_name"];
  //     // st4=response["results"][0]["address_components"][6]["long_name"];
  //     // placeAddress=st1 + " ,"+st2+ " ,"+st3 + " ," +st4 +"";
  //     //
  //
  //     Provider.of<AppData>(context, listen: false)
  //         .updatePickUpLocationAddress(userPickUpAddress);
  //   }
  //   return placeAddress;
  // }

  static Future<DirectioDetail> obtainPlaceDirectionsDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition
        .latitude},${finalPosition.longitude}&origin=${initialPosition
        .latitude},${initialPosition.longitude}&key=$mapkey";
    var res = await RequestAssistant.getRequest(directionUrl);
    if (res == "failed") {
      throw Exception('Failed to fetch directions');
    }

    DirectioDetail directioDetail = DirectioDetail();
    directioDetail.encodedPoints =
    res["routes"][0]["overview_polyline"]["points"];

    directioDetail.distanceText =
    res["routes"][0]["legs"][0]["distance"]["text"];
    directioDetail.distanceValue =
    res["routes"][0]["legs"][0]["distance"]["value"];

    directioDetail.durationText =
    res["routes"][0]["legs"][0]["duration"]["text"];

    directioDetail.durationValue =
    res["routes"][0]["legs"][0]["duration"]["value"];

    return directioDetail;
  }

  static int caculatePrice(DirectioDetail directioDetail) {
    double timeTraveledFare = (directioDetail.durationValue! / 60) * 0.20;
    double distanceTraveledFare = (directioDetail.distanceValue! / 1000) * 0.2;
    double totalPrice = timeTraveledFare + distanceTraveledFare;
    return totalPrice.truncate();
  }

  // static void getCurrentOnlineUserInfo() async {
  //   firebaseUser = await FirebaseAuth.instance.currentUser;
  //   String userId = firebaseUser!.uid;
  //
  //   DatabaseReference reference =
  //   FirebaseDatabase.instance.ref().child("users").child(userId);
  //   reference.once().then((DatabaseEvent databaseEvent) {
  //     if (databaseEvent.snapshot.value != null) {
  //       final dataSnapshot = databaseEvent.snapshot;
  //       userCurrentInf = Users.fromSnapshot(dataSnapshot);
  //       print(userCurrentInf!.name);
  //     }
  //   });
  // }
static void disabeLiveLocationUpdate()
{
  homeTabPageStreamSubscription!.pause();
  Geofire.removeLocation(currentfirebaseUser!.uid);

}
  static void enableLiveLocationUpdate()
  {
    homeTabPageStreamSubscription!.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);

  }

  static void retriveHistoryInfo(context) {
    driverRref.child(currentfirebaseUser!.uid).child("earnings").once().then((
        DatabaseEvent event) {
      if (event.snapshot.value != null) {
        String earnings = event.snapshot.value.toString();
        Provider.of<AppData>(context,listen: false).updateEarnings(earnings);
      }
    });
  }




}
