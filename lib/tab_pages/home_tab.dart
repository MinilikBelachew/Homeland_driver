import 'dart:async';
import 'dart:ui';

import 'package:driver/assistant/assistant_methods.dart';
import 'package:driver/config_maps.dart';
import 'package:driver/main.dart';
import 'package:driver/models/drivers.dart';
import 'package:driver/notification/push_notification_service.dart';
import 'package:driver/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {
  HomeTabPage({super.key});
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  var geoLocator = Geolocator();
  String driverStatusText = "offline Now - Go Online";

  Color driverStatusColor = Colors.red;
  bool isDriverAvailable = false;

  LocationPermission? _locationPermission;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController newGoogleMapController;

  void locateCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    // await AssistantMethods.searchCoordinateAddress(position, context);
    // print("Address" + address);
  }

  checKLocationPermission() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState() {
    super.initState();
    checKLocationPermission();
    getCurrentDriverInfo();
  }


  getRatings()
  {
    driverRref.child(currentfirebaseUser!.uid).child("ratings").once().then((
        DatabaseEvent event) {
      if (event.snapshot.value != null) {

        double ratings=double.parse(event.snapshot.value.toString());
        setState(() {
          startCounter=ratings;

        });

        if(startCounter <= 1)
        {
          setState(() {
            title="Very Bad";

          });

          return;

        }
        if(startCounter <= 2)
        {
          setState(() {
            title="Bad";

          });
          return;


        }
        if(startCounter <= 3)
        {
          setState(() {
            title="Good";

          });
          return;

        }
        if(startCounter <= 4)
        {
          setState(() {
            title="Very Good";

          });
          return;

        }
        if(startCounter <= 5)
        {
          setState(() {
            title="Excellent";

          });
          return;


        }

      }
    });

  }

  void getCurrentDriverInfo() async
  {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;

    driverRref.child(currentfirebaseUser!.uid).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(event.snapshot);
      }
      // Or any other relevant value
    });




    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
     pushNotificationService.getToken();

     AssistantMethods.retriveHistoryInfo(context);
     getRatings();

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            newGoogleMapController = controller;

            locateCurrentPosition();
          },
        ),
        Container(
          height: 140,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (isDriverAvailable != true) {
                      makeDriverOnlineNow();
                      getLocationUpdates();

                      setState(() {
                        driverStatusColor = Colors.green;
                        driverStatusText = "Online Now";
                        isDriverAvailable = true;
                      });
                      displayToastMessage("You Are online now", context);
                    } else {
                      setState(() {
                        driverStatusColor = Colors.red;
                        driverStatusText = "Online Offline";
                        isDriverAvailable = false;
                        makeDriverOffline();
                      });
                      displayToastMessage("You Are offline now", context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        driverStatusText,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: driverStatusColor),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.phonelink_ring,
                        color: Colors.black,
                        size: 26,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    Geofire.initialize("AvailabeDrivers");
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude,
        currentPosition.longitude);

    rideRequestRref.set("searching");

    rideRequestRref.onValue.listen((event) {});
  }

  void getLocationUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(
            currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOffline() {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRref.onDisconnect();
    rideRequestRref.remove();
   // rideRequestRref = null;
  }
}
