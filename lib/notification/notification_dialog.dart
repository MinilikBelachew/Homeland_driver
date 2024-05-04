import 'package:driver/assistant/assistant_methods.dart';
import 'package:driver/config_maps.dart';
import 'package:driver/main.dart';
import 'package:driver/models/ride_details.dart';
import 'package:driver/screens/new_request_screen.dart';
import 'package:driver/screens/signup_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotificationDialog extends StatelessWidget {
// NotificationDialog({super.key});

  final RideDetails rideDetails;

  NotificationDialog({required this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      elevation: 1,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset('images/taxi.png', width: 120),
            SizedBox(
              height: 18,
            ),
            Text(
              "New Request",
              style: TextStyle(fontFamily: "Brand-Bold", fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.pickup_address!,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.dropoff_address!,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                    height: 2,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            // Keep the green background
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            // Set text color to black
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(fontSize: 14.0), // Maintain font size
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(70.0, 40.0)),
                            // Increase button width & height
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(
                                    horizontal:
                                        16.0)), // Add some horizontal padding
                          ),
                          onPressed: () {
                            assetsAudioPlayer.stop();
                            Navigator.pop(context);
                            // Your button press action here
                          },
                          child: Text(
                            "Cancel",
                          ),
                        ),
                        SizedBox(
                          width: 70,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            // Set background color to red
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            // Set text color to black
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(fontSize: 14.0), // Maintain font size
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(70.0, 40.0)),
                            // Increase button width & height
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(
                                    horizontal:
                                        16.0)), // Add some horizontal padding
                          ),
                          onPressed: () {
                            assetsAudioPlayer.stop();
                            checkAvailabilityOfRide(context);
                            // Your button press action here
                          },
                          child: Text(
                            "Accept",
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRref.once().then((DatabaseEvent event) {
      Navigator.pop(context);
      DataSnapshot? dataSnapShot = event.snapshot;
      String theRideId = "";
      if (dataSnapShot != null && dataSnapShot.value != null) {
        theRideId = dataSnapShot.value.toString();
      }
      else {
        displayToastMessage("Ride not exists", context);
      }
      if(theRideId == rideDetails.ride_request_id)
        {
          rideRequestRref.set("accepted");

          AssistantMethods.disabeLiveLocationUpdate();
          Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRequestScreen(rideDetails: rideDetails)));
        }
      else if(theRideId ==" cancelled")
        {
          displayToastMessage("Ride has been Cancelled", context);
        }
      else if(theRideId == "timeout")
        {
          displayToastMessage("Ride Time out", context);
        }
      else
        {
          displayToastMessage("Ride not exists", context);
        }
    }).catchError((error) {
      print("Erhfgdgdgdgdgdgdgdgdror: $error");
      displayToastMessage("Error occurred: $error", context);
    });
  }
}
