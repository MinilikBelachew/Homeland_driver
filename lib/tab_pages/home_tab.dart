import 'dart:async';
import 'dart:ui';
import 'package:driver/assistant/assistant_methods.dart';
import 'package:driver/config_maps.dart';
import 'package:driver/main.dart';
import 'package:driver/models/drivers.dart';
import 'package:driver/notification/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../data_handler/app_data.dart';
import '../screens/signup_screen.dart';

class HomeTabPage extends StatefulWidget {

  HomeTabPage({Key? key}) : super(key: key);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  var geoLocator = Geolocator();
  String driverStatusText = "offline Now";
  Color driverStatusColor = Colors.red;
  bool isDriverAvailable = false;
  LocationPermission? _locationPermission;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checKLocationPermission();
    getCurrentDriverInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      if (isDriverAvailable) {
        makeDriverOffline();
      }
    }
  }

  void checKLocationPermission() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void locateCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _toggleDriverStatus() {
    setState(() {
      isDriverAvailable = !isDriverAvailable;
      AppData languageProvider = Provider.of<AppData>(context, listen: false);
      var language = languageProvider.isEnglishSelected;
      if (isDriverAvailable) {
        makeDriverOnlineNow();
        getLocationUpdates();
        driverStatusColor = Colors.green;
        driverStatusText = language ? "Online Now" : "መስመር ላይ ነዎት";
        displayToastMessage(
            language ? "You Are online now" : "አሁን መስመር ላይ ነዎት።", context);
      } else {
        makeDriverOffline();
        driverStatusColor = Colors.red;
        driverStatusText = language ? "Offline now" : "ከመስመር ውጭ ነዎት";
        displayToastMessage(
            language ? "You Are offline now" : "አሁን ከመስመር ውጭ ነዎት።", context);
      }
    });
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;
    driverRref
        .child(currentfirebaseUser!.uid)
        .once()
        .then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(event.snapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    AssistantMethods.retriveHistoryInfo(context);
    getRatings();
  }

  void getRatings() {
    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;
    driverRref
        .child(currentfirebaseUser!.uid)
        .child("ratings")
        .once()
        .then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        double ratings = double.parse(event.snapshot.value.toString());
        setState(() {
          startCounter = ratings;
        });

        if (startCounter <= 1) {
          setState(() {
            title = language ? "Very Bad" : "በጣም መጥፎ";
          });
          return;
        }
        if (startCounter <= 2) {
          setState(() {
            title = language ? "Bad" : "መጥፎ";
          });
          return;
        }
        if (startCounter <= 3) {
          setState(() {
            title = language ? "Good" : "ጥሩ";
          });
          return;
        }
        if (startCounter <= 4) {
          setState(() {
            title = language ? "Very Good" : "በጣም ጥሩ";
          });
          return;
        }
        if (startCounter <= 5) {
          setState(() {
            title = language ? "Excellent" : "በጣም በጣም ጥሩ";
          });
          return;
        }
      }
    });
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
    print("working");
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line to call the super method
    return WillPopScope(
      onWillPop: () async {
        if (isDriverAvailable) {
          makeDriverOffline();
        }
        return true;
      },
      child: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              padding: EdgeInsets.only(top: 400),
              zoomControlsEnabled: true,
              initialCameraPosition: HomeTabPage._kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newGoogleMapController = controller;
                locateCurrentPosition();
              },
            ),
            Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _toggleDriverStatus(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 55),
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isDriverAvailable
                          ? [Colors.green.shade400, Colors.greenAccent]
                          : [Colors.red.shade400, Colors.redAccent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        driverStatusText,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        isDriverAvailable
                            ? Icons.phonelink_ring
                            : Icons.cloud_off_outlined,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:ui';
// import 'package:driver/assistant/assistant_methods.dart';
// import 'package:driver/config_maps.dart';
// import 'package:driver/main.dart';
// import 'package:driver/models/drivers.dart';
// import 'package:driver/notification/push_notification_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import '../data_handler/app_data.dart';
// import '../screens/signup_screen.dart';
//
// class HomeTabPage extends StatefulWidget {
//   HomeTabPage({Key? key}) : super(key: key);
//
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   @override
//   _HomeTabPageState createState() => _HomeTabPageState();
// }
//
// class _HomeTabPageState extends State<HomeTabPage> with AutomaticKeepAliveClientMixin {
//   var geoLocator = Geolocator();
//   String driverStatusText = "offline Now";
//   Color driverStatusColor = Colors.red;
//   bool isDriverAvailable = false;
//   LocationPermission? _locationPermission;
//   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//   late GoogleMapController newGoogleMapController;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     checKLocationPermission();
//     getCurrentDriverInfo();
//   }
//
//   void checKLocationPermission() async {
//     _locationPermission = await Geolocator.requestPermission();
//     if (_locationPermission == LocationPermission.denied) {
//       _locationPermission = await Geolocator.requestPermission();
//     }
//   }
//
//   void locateCurrentPosition() async {
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     currentPosition = position;
//     LatLng latLngPosition = LatLng(position.latitude, position.longitude);
//     CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
//     newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//   }
//
//   void _toggleDriverStatus() {
//     setState(() {
//       isDriverAvailable = !isDriverAvailable;
//       AppData languageProvider = Provider.of<AppData>(context, listen: false);
//       var language = languageProvider.isEnglishSelected;
//       if (isDriverAvailable) {
//         makeDriverOnlineNow();
//         getLocationUpdates();
//         driverStatusColor = Colors.green;
//         driverStatusText = language ? "Online Now" : "መስመር ላይ ነዎት";
//         displayToastMessage(language ? "You Are online now" : "አሁን መስመር ላይ ነዎት።", context);
//       } else {
//         makeDriverOffline();
//         driverStatusColor = Colors.red;
//         driverStatusText = language ? "Offline now" : "ከመስመር ውጭ ነዎት";
//         displayToastMessage(language ? "You Are offline now" : "አሁን ከመስመር ውጭ ነዎት።", context);
//       }
//     });
//   }
//
//   void getCurrentDriverInfo() async {
//     currentfirebaseUser = await FirebaseAuth.instance.currentUser;
//     driverRref.child(currentfirebaseUser!.uid).once().then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         driversInformation = Drivers.fromSnapshot(event.snapshot);
//       }
//     });
//
//     PushNotificationService pushNotificationService = PushNotificationService();
//     pushNotificationService.initialize(context);
//     pushNotificationService.getToken();
//
//     AssistantMethods.retriveHistoryInfo(context);
//     getRatings();
//   }
//
//   void getRatings() {
//     AppData languageProvider = Provider.of<AppData>(context);
//     var language = languageProvider.isEnglishSelected;
//     driverRref.child(currentfirebaseUser!.uid).child(language ? "ratings" : "የእርስዎ ደረጃዎች").once().then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         double ratings = double.parse(event.snapshot.value.toString());
//         setState(() {
//           startCounter = ratings;
//         });
//
//         if (startCounter <= 1) {
//           setState(() {
//             title = language ? "Very Bad" : "በጣም መጥፎ";
//           });
//           return;
//         }
//         if (startCounter <= 2) {
//           setState(() {
//             title = language ? "Bad" : "መጥፎ";
//           });
//           return;
//         }
//         if (startCounter <= 3) {
//           setState(() {
//             title = language ? "Good" : "ጥሩ";
//           });
//           return;
//         }
//         if (startCounter <= 4) {
//           setState(() {
//             title = language ? "Very Good" : "በጣም ጥሩ";
//           });
//           return;
//         }
//         if (startCounter <= 5) {
//           setState(() {
//             title = language ? "Excellent" : "በጣም በጣም ጥሩ";
//           });
//           return;
//         }
//       }
//     });
//   }
//
//   void makeDriverOnlineNow() async {
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     currentPosition = position;
//     Geofire.initialize("AvailabeDrivers");
//     Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);
//     rideRequestRref.set("searching");
//     rideRequestRref.onValue.listen((event) {});
//     print("working");
//   }
//
//   void getLocationUpdates() {
//     homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
//       currentPosition = position;
//       if (isDriverAvailable == true) {
//         Geofire.setLocation(currentfirebaseUser!.uid, position.latitude, position.longitude);
//       }
//       LatLng latLng = LatLng(position.latitude, position.longitude);
//       newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
//     });
//   }
//
//   void makeDriverOffline() {
//     Geofire.removeLocation(currentfirebaseUser!.uid);
//     rideRequestRref.onDisconnect();
//     rideRequestRref.remove();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Add this line to call the super method
//     return SafeArea(
//       child: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             myLocationEnabled: true,
//             zoomGesturesEnabled: true,
//             padding: EdgeInsets.only(top: 400),
//             zoomControlsEnabled: true,
//             initialCameraPosition: HomeTabPage._kGooglePlex,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               newGoogleMapController = controller;
//               locateCurrentPosition();
//             },
//           ),
//           Material(
//             color: Colors.transparent,
//             child: GestureDetector(
//               onTap: () => _toggleDriverStatus(),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 55),
//                 height: 100,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     colors: isDriverAvailable ? [Colors.green.shade400, Colors.greenAccent] : [Colors.red.shade400, Colors.redAccent],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       blurRadius: 5,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       driverStatusText,
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Spacer(),
//                     Icon(
//                       isDriverAvailable ? Icons.phonelink_ring : Icons.cloud_off_outlined,
//                       size: 30,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:ui';
//
// import 'package:driver/assistant/assistant_methods.dart';
// import 'package:driver/config_maps.dart';
// import 'package:driver/main.dart';
// import 'package:driver/models/drivers.dart';
// import 'package:driver/notification/push_notification_service.dart';
// import 'package:driver/screens/signup_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
//
// import '../data_handler/app_data.dart';
//
// class HomeTabPage extends StatefulWidget {
//
//
//
//
//
//
//
//
//
//   HomeTabPage({super.key});
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   @override
//   State<HomeTabPage> createState() => _HomeTabPageState();
// }
//
// class _HomeTabPageState extends State<HomeTabPage> {
//   var geoLocator = Geolocator();
//   String driverStatusText = "offline Now";
//
//   Color driverStatusColor = Colors.red;
//   bool isDriverAvailable = false;
//
//   LocationPermission? _locationPermission;
//
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//
//   late GoogleMapController newGoogleMapController;
//
//   void locateCurrentPosition() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     currentPosition = position;
//     LatLng latLngPosition = LatLng(position.latitude, position.longitude);
//
//     CameraPosition cameraPosition =
//         new CameraPosition(target: latLngPosition, zoom: 14);
//
//     newGoogleMapController
//         .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//
//     // String address =
//     // await AssistantMethods.searchCoordinateAddress(position, context);
//     // print("Address" + address);
//   }
//
//   checKLocationPermission() async {
//     _locationPermission = await Geolocator.requestPermission();
//     if (_locationPermission == LocationPermission.denied) {
//       _locationPermission = await Geolocator.requestPermission();
//     }
//   }
//
//   void initState() {
//     super.initState();
//     checKLocationPermission();
//     getCurrentDriverInfo();
//   }
//
//   void _toggleDriverStatus() {
//     setState(() {
//       isDriverAvailable = !isDriverAvailable;
//       AppData languageProvider = Provider.of<AppData>(context,listen: false);
//       var language = languageProvider.isEnglishSelected;
//       if (isDriverAvailable) {
//         makeDriverOnlineNow();
//         getLocationUpdates();
//         driverStatusColor = Colors.green;
//         driverStatusText = language?"Online Now":"መስመር ላይ ነዎት";
//         displayToastMessage(language?"You Are online now":"አሁን መስመር ላይ ነዎት።", context);
//       } else {
//         makeDriverOffline();
//         driverStatusColor = Colors.red;
//         driverStatusText = language?"Offline now":"ከመስመር ውጭ ነዎት";
//         displayToastMessage(language?"You Are offline now":"አሁን ከመስመር ውጭ ነዎት።", context);
//       }
//     });
//   }
//
//   getRatings() {
//     AppData languageProvider = Provider.of<AppData>(context);
//     var language = languageProvider.isEnglishSelected;
//     driverRref
//         .child(currentfirebaseUser!.uid)
//         .child(language?"ratings":"የእርስዎ ደረጃዎች")
//         .once()
//         .then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         double ratings = double.parse(event.snapshot.value.toString());
//         setState(() {
//           startCounter = ratings;
//         });
//
//         if (startCounter <= 1) {
//           setState(() {
//             title =language? "Very Bad":"በጣም መጥፎ";
//           });
//
//           return;
//         }
//         if (startCounter <= 2) {
//           setState(() {
//             title = language?"Bad":"መጥፎ";
//           });
//           return;
//         }
//         if (startCounter <= 3) {
//           setState(() {
//             title =language? "Good":"ጥሩ";
//           });
//           return;
//         }
//         if (startCounter <= 4) {
//           setState(() {
//             title = language?"Very Good":"በጣም ጥሩ";
//           });
//           return;
//         }
//         if (startCounter <= 5) {
//           setState(() {
//             title = language?"Excellent":"በጣም በጣም ጥሩ";
//           });
//           return;
//         }
//       }
//     });
//   }
//
//   void getCurrentDriverInfo() async {
//     currentfirebaseUser = await FirebaseAuth.instance.currentUser;
//
//     driverRref
//         .child(currentfirebaseUser!.uid)
//         .once()
//         .then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         driversInformation = Drivers.fromSnapshot(event.snapshot);
//       }
//       // Or any other relevant value
//     });
//
//     PushNotificationService pushNotificationService = PushNotificationService();
//     pushNotificationService.initialize(context);
//     pushNotificationService.getToken();
//
//     AssistantMethods.retriveHistoryInfo(context);
//     getRatings();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             myLocationEnabled: true,
//             zoomGesturesEnabled: true,
//             padding: EdgeInsets.only(top: 400),
//             zoomControlsEnabled: true,
//             initialCameraPosition: HomeTabPage._kGooglePlex,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               newGoogleMapController = controller;
//
//               locateCurrentPosition();
//             },
//           ),
//
//           Material(
//             color: Colors.transparent, // For ripple effect
//             child: GestureDetector(
//               onTap: () => _toggleDriverStatus(),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 55),
//                 height: 100,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: isDriverAvailable
//                           ? [Colors.green.shade400, Colors.greenAccent]
//                           : [Colors.red.shade400, Colors.redAccent],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.grey.withOpacity(0.2),
//                           blurRadius: 5,
//                           spreadRadius: 2)
//                     ] // Subtle shadow
//                     ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       driverStatusText,
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Spacer(),
//                     Icon(
//                       isDriverAvailable
//                           ? Icons.phonelink_ring
//                           : Icons.cloud_off_outlined,
//                       size: 30,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Container(
//           //   height: 140,
//           //   width: double.infinity,
//           //   decoration: BoxDecoration(
//           //     borderRadius: BorderRadius.circular(20), // Rounded corners
//           //     gradient: LinearGradient( // Gradient background
//           //       colors: isDriverAvailable ? [Colors.green, Colors.greenAccent] : [Colors.red, Colors.redAccent],
//           //     ),
//           //   ),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.center,
//           //     children: [
//           //       Text(
//           //         driverStatusText,
//           //         style: TextStyle(
//           //           fontSize: 20,
//           //           fontWeight: FontWeight.bold,
//           //           color: Colors.white, // White text for better contrast
//           //         ),
//           //       ),
//           //       Spacer(), // Space between text and button
//           //       IconButton(
//           //         icon: Icon(
//           //           Icons.phonelink_ring,
//           //           color: Colors.white, // White icon for better contrast
//           //           size: 26,
//           //         ),
//           //         onPressed: () => _toggleDriverStatus(), // Cleaner function name
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   void makeDriverOnlineNow() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     currentPosition = position;
//     Geofire.initialize("AvailabeDrivers");
//     Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude,
//         currentPosition.longitude);
//
//     rideRequestRref.set("searching");
//
//     rideRequestRref.onValue.listen((event) {});
//     print("working");
//   }
//
//   void getLocationUpdates() {
//     homeTabPageStreamSubscription =
//         Geolocator.getPositionStream().listen((Position position) {
//       currentPosition = position;
//       if (isDriverAvailable == true) {
//         Geofire.setLocation(
//             currentfirebaseUser!.uid, position.latitude, position.longitude);
//       }
//       LatLng latLng = LatLng(position.latitude, position.longitude);
//       newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
//     });
//   }
//
//   void makeDriverOffline() {
//     Geofire.removeLocation(currentfirebaseUser!.uid);
//     rideRequestRref.onDisconnect();
//     rideRequestRref.remove();
//     // rideRequestRref = null;
//   }
// }
//
// //
// // Container(
// // height: 140,
// // width: double.infinity,
// // color: Colors.black54,
// // ),
// // Positioned(
// // top: 60,
// // left: 0,
// // right: 0,
// // child: Row(
// // mainAxisAlignment: MainAxisAlignment.center,
// // children: [
// // Padding(
// // padding: EdgeInsets.symmetric(horizontal: 16),
// // child: ElevatedButton(
// // onPressed: () {
// // if (isDriverAvailable != true) {
// // makeDriverOnlineNow();
// // getLocationUpdates();
// //
// // setState(() {
// // driverStatusColor = Colors.green;
// // driverStatusText = "Online Now";
// // isDriverAvailable = true;
// // });
// // displayToastMessage("You Are online now", context);
// // } else {
// // setState(() {
// // driverStatusColor = Colors.red;
// // driverStatusText = "Online Offline";
// // isDriverAvailable = false;
// // makeDriverOffline();
// // });
// // displayToastMessage("You Are offline now", context);
// // }
// // },
// // child: Row(
// // mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // children: [
// // Text(
// // driverStatusText,
// // style: TextStyle(
// // fontSize: 20,
// // fontWeight: FontWeight.bold,
// // color: driverStatusColor),
// // ),
// // SizedBox(
// // width: 10,
// // ),
// // Icon(
// // Icons.phonelink_ring,
// // color: Colors.black,
// // size: 26,
// // )
// // ],
// // ),
// // ),
// // ),
// // ],
// // ),
// // )
