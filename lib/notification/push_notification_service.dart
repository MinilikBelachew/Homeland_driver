//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as audio_player_notification;
import 'package:driver/config_maps.dart'; // Assuming this is your configuration file
import 'package:driver/main.dart'; // Assuming this is your app's main entry point
import 'package:driver/models/ride_details.dart';
import 'package:driver/notification/notification_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import the dart:io library

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging =
      FirebaseMessaging.instance; // Use instance

  Future<void> initialize(context) async {
    // Request notification permissions (Android only)
    if (Platform.isAndroid) {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false, // Optional, adjust based on your needs
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else {
        print('User declined or has not granted notification permission');
      }
    }

    // Handle messages in foreground and background
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message), context);
      // Extract ride request ID
      // Handle the message data and ride request ID here (e.g., navigate to a screen)
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        retrieveRideRequestInfo(getRideRequestId(message),context);

        // Example handling (replace with your app's logic)


    });
  }

  String getRideRequestId(RemoteMessage message) {
    if (message.data == null || !message.data.containsKey("ride_request_id")) {
      return ""; // Handle missing or invalid message data gracefully
    }

    final rideRequestId = message.data["ride_request_id"];
    print("Ride request ID: $rideRequestId"); // Consolidated print statement

    return rideRequestId;
  }

  Future<String?> getToken() async {
    String? token = await firebaseMessaging.getToken();
    if (token != null) {
      print("P: $token");
      // Update token in database or perform other actions

      driverRref.child(currentfirebaseUser!.uid).child("token").set(token);
    }

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
    return token; // Optionally return the token
  }

  Future<void> retrieveRideRequestInfo(
      String rideRequestId, BuildContext context) async {
    final event = await FirebaseDatabase.instance
        .ref()
        .child("Ride Request")
        .child(rideRequestId)
        .once();

    print("Snapshot value for $rideRequestId: ${event.snapshot.value}");

    if (event.snapshot.value != null) {
      final data = event.snapshot.value;
      print("Data type: ${data.runtimeType}");

      if (data is Map<dynamic, dynamic>) {
        print("Data keys: ${data.keys}");




assetsAudioPlayer.open(audio_player_notification.Audio("sounds/alert2.wav"));
assetsAudioPlayer.play();


        double? pickUpLocationLat =
            double.tryParse(data["pickup"]!["latitude"].toString()) ?? 0.0;
        double? pickUpLocationLng =
            double.tryParse(data["pickup"]!["longitude"].toString()) ?? 0.0;

        String? pickUpAddress = data["pickup_address"] as String?;

        double? dropOffLocationLat =
            double.tryParse(data["dropoff"]!["latitude"].toString()) ?? 0.0;
        double? dropOffLocationLng =
            double.tryParse(data["dropoff"]!["longitude"].toString()) ?? 0.0;
        String? dropOffAddress = data["dropoff_address"] as String?;

        String? payment_method = data["payment_method"] as String?;
        String? package_description = data["package_description"] as String?;

        String? rider_name=data["name"];
        String? rider_phone=data["phone"];



        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.payment_method = payment_method;
        rideDetails.package_description=package_description;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup =
            LatLng(pickUpLocationLat as double, pickUpLocationLng as double)
                as LatLng?;
        rideDetails.dropoff =
            LatLng(dropOffLocationLat as double, dropOffLocationLng as double)
                as LatLng?;

        rideDetails.rider_name=rider_name;
        rideDetails.rider_phone=rider_phone;

        print("Ride Details:");
        print(payment_method);
        print("Pickup Address: ${rideDetails.pickup_address}");
        print("Dropoff Address: ${rideDetails.dropoff_address}");
        print("Pickup: ${rideDetails.pickup}");
        print("Dropoff: ${rideDetails.dropoff}");
        print("Payment Method: ${rideDetails.payment_method}");

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                NotificationDialog(rideDetails: rideDetails));

        // Continue with the rest of the parsing logic...
      }
    } else {
      print("No data found for ride request ID: $rideRequestId");
    }
  }
}

// import 'package:driver/config_maps.dart'; // Assuming this is your configuration file
// import 'package:driver/main.dart'; // Assuming this is your app's main entry point
// import 'package:driver/models/ride_details.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'dart:io';
//
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import the dart:io library
//
// class PushNotificationService {
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance; // Use instance
//
//   Future<void> initialize() async {
//     // Request notification permissions (Android only)
//     if (Platform.isAndroid) {
//       NotificationSettings settings = await firebaseMessaging.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false, // Optional, adjust based on your needs
//       );
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print('User granted notification permission');
//       } else {
//         print('User declined or has not granted notification permission');
//       }
//     }
//
//     // Handle messages in foreground and backgroundat
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("onMessage received: $message");
//       if (message.data != null) {
//         print("Data payload: ${message.data}");
//         final rideRequestId = getRideRequestId(message);
//
//         retrieveRideRequestInfo(getRideRequestId(message));
//         // Extract ride request ID
//         // Handle the message data and ride request ID here (e.g., navigate to a screen)
//
//         // Example handling (replace with your app's logic)
//         if (rideRequestId.isNotEmpty) {
//           // Navigate to a screen displaying the ride request details
//           // or perform other actions based on the ride request ID
//         }
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("onMessageOpenedApp: $message");
//       if (message.data != null) {
//         print("Data payload: ${message.data}");
//         final rideRequestId = getRideRequestId(message); // Extract ride request ID
//         // Navigate to a specific screen or perform actions based on data and ride request ID
//         retrieveRideRequestInfo(getRideRequestId(message));
//
//         // Example handling (replace with your app's logic)
//         if (rideRequestId.isNotEmpty) {
//           // Navigate to a screen displaying the ride request details
//           // or perform other actions based on the ride request ID and data
//         }
//       }
//     });
//   }
//
//   String getRideRequestId(RemoteMessage message) {
//     if (message.data == null || !message.data.containsKey("ride_request_id")) {
//       return ""; // Handle missing or invalid message data gracefully
//     }
//
//     final rideRequestId = message.data["ride_request_id"];
//     print("Ride request ID: $rideRequestId"); // Consolidated print statement
//
//     return rideRequestId;
//   }
//
//   Future<String?> getToken() async {
//     String? token = await firebaseMessaging.getToken();
//     if (token != null) {
//       print("Push notification token: $token");
//       // Update token in database or perform other actions
//       driverRref.child(currentfirebaseUser!.uid).child("token").set(token);
//     }
//
//     firebaseMessaging.subscribeToTopic("alldrivers");
//     firebaseMessaging.subscribeToTopic("allusers");
//     return token; // Optionally return the token
//   }
//
//   Future<void> retrieveRideRequestInfo(String rideRequestId) async {
//     final event = await FirebaseDatabase.instance
//         .reference()
//         .child("Ride Request")
//         .child(rideRequestId)
//         .once();
//
//     print("Snapshot value for $rideRequestId: ${event.snapshot.value}");
//
//     if (event.snapshot.value != null) {
//       final data = event.snapshot.value;
//       print("Data type: ${data.runtimeType}");
//
//       if (data is Map<dynamic, dynamic>) {
//         print("Data keys: ${data.keys}");
//
//         final driverId = data["driver_id"] as String?;
//         final pickupData = data["pickup"] as Map<dynamic, dynamic>?; // Adjusted type
//         final dropoffData = data["dropoff"] as Map<dynamic, dynamic>?; // Adjusted type
//         final createdAt = data["created_at"] as String?;
//         final pickupAddress = data["pickup_address"] as String?;
//         final dropoffAddress = data["dropoff_address"] as String?;
//         final paymentMethod = data["payment_method"] as String?;
//
//         print("Driver ID: $driverId");
//         print("Pickup Data: $pickupData");
//         print("Dropoff Data: $dropoffData");
//         print("Created At: $createdAt");
//         print("Pickup Address: $pickupAddress");
//         print("Dropoff Address: $dropoffAddress");
//         print("Payment Method: $paymentMethod");
//
//         // Continue with the rest of the parsing logic...
//       }
//     } else {
//       print("No data found for ride request ID: $rideRequestId");
//     }
//   }
//
//
//
//
//
// }
//
//

// import 'package:driver/config_maps.dart';
// import 'package:driver/main.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'dart:io'; // Import the dart:io library
//
// class PushNotificationService {
//
//
//
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance; // Use instance
//
//   Future<void> initialize() async {
//     // Request notification permissions (Android only)
//     if (Platform.isAndroid) {
//       NotificationSettings settings = await firebaseMessaging.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false, // Optional, adjust based on your needs
//       );
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print('User granted notification permission');
//       } else {
//         print('User declined or has not granted notification permission');
//       }
//     }
//
//     // Handle messages in foreground and background
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       getRideRequestId(message);
//
//       print("onMessage received: $message");
//       // Handle the message data (if any)
//       if (message.data != null) {
//         print("Data payload: ${message.data}");
//         // Extract and process data from message.data
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       getRideRequestId(message);
//       print("onMessageOpenedApp: $message");
//       // Handle the message data when the app is opened from a notification
//       if (message.data != null) {
//         print("Data payload: ${message.data}");
//         // Navigate to a specific screen or perform actions based on data
//       }
//     });
//
//   }
//
//
//   Future<String?> getToken() async {
//     String? token = await firebaseMessaging.getToken();
//     if (token != null) {
//
//       print("jhgdsfffffffffffffffffffa");
//       print(token);
//       // Update token in database or perform other actions
//       driverRref.child(currentfirebaseUser!.uid).child("token").set(token);
//     }
//
//     firebaseMessaging.subscribeToTopic("alldrivers");
//     firebaseMessaging.subscribeToTopic("allusers");
//     return token; // Optionally return the token
//   }
//
//
//   String getRideRequestId(dynamic message)
//   {
//
//     String rideRequestId="";
//     if(Platform.isAndroid)
//   {
//     print("requestsjgakkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
//     rideRequestId=message["data"]["ride_request_id"];
//     print(rideRequestId);
//   }
//     else
//       {
//         print("requestsjgakkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
//         rideRequestId=message["ride_request_id"];
//         print(rideRequestId);
//       }
//     return rideRequestId;
//
//   }
// }
//
//

// import 'package:driver/config_maps.dart';
// import 'package:driver/main.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// class PushNotificationService
// {
//
//
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
//
//   Future initialize() async{
//     firebaseMessaging.configure(
//       onMessage: (Map<String,dynamic> message) async{
//         print("onMessage $message");
//
//       },
//       onLaunch: (Map<String, dynamic> message) async
//         {
//           print("onLaunch $message");
//
//         },
//         onResume: (Map<String, dynamic> message) async
//         {
//           print("onResume $message");
//
//         }
//     );
//   }
//
//   Future<String> getToken() async
//   {
//     String? token = await firebaseMessaging.getToken();
//     driverRref.child(currentfirebaseUser!.uid).child("token").set(token);
//
//     firebaseMessaging.subscribeToTopic("alldrivers");
//     firebaseMessaging.subscribeToTopic("allusers");
//
//
//
//   }
// }
