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
import 'package:provider/provider.dart';

import '../data_handler/app_data.dart';

class NotificationDialog extends StatelessWidget {
// NotificationDialog({super.key});

  final RideDetails rideDetails;

  NotificationDialog({required this.rideDetails});

  @override
  Widget build(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context,listen: false);
    var language = languageProvider.isEnglishSelected;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent, // Maintain transparency
      elevation: 0, // Remove default elevation

      child: ClipRRect(
        // Clip rounded corners for content
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            // Add some padding for aesthetics
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  // New Request title with icon
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text( language?
                      "New Request":"አዲስ የጉዞ ጥያቄ።",
                      style: TextStyle(
                        fontFamily: "Brand-Bold", // Assuming existing font
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(0.2), // Light green background
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'images/img.icons8.png', // Assuming valid image path
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Spacing between sections

                // Ride details section with icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.archive_outlined, // Material Icon for package
                      color: Colors.green, // Green color for icons
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rideDetails.package_description!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Smaller spacing between info

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined, // Material Icon for pickup
                      color: Colors.green, // Green color for icons
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rideDetails.pickup_address!,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4), // Smaller spacing between pickup & dropoff

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.pin_drop_outlined, // Material Icon for dropoff
                      color: Colors.green, // Green color for icons
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rideDetails.dropoff_address!,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24), // Spacing between sections

                Divider(
                  // Use a thin divider
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2), // Light grey color
                ),

                SizedBox(height: 16), // Spacing between sections

                // Buttons section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        // Use TextButton.styleFrom
                        backgroundColor:
                            Colors.red.withOpacity(0.1), // Light red background
                        foregroundColor: Colors.red, // Red text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      onPressed: () {
                        assetsAudioPlayer.stop();
                        Navigator.pop(context);
                      },
                      child: Text(
                        language?
                        "Cancel":"መሰረዝ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Use ElevatedButton.styleFrom
                        backgroundColor: Colors.green, // Green background
                        foregroundColor: Colors.white, // White text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      onPressed: () {
                        assetsAudioPlayer.stop();
                        checkAvailabilityOfRide(context);
                      },
                      child: Text(language?
                        "Accept":"ተቀበል",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    //   Dialog(
    //
    //
    //
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   backgroundColor: Colors.transparent,
    //   elevation: 1,
    //   child: Container(
    //     margin: EdgeInsets.all(5),
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(5),
    //     ),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         SizedBox(
    //           height: 30,
    //         ),
    //         Image.asset('images/icons5.png', width: 120),
    //         SizedBox(
    //           height: 8,
    //         ),
    //         Text(
    //           "New Request",
    //           style: TextStyle(fontFamily: "Brand-Bold", fontSize: 18),
    //         ),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Padding(
    //           padding: EdgeInsets.all(18),
    //           child: Column(
    //             children: [
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Image.asset(
    //                     "images/location_pin.gif",
    //                     height: 36,
    //                     width: 36,
    //                   ),
    //                   SizedBox(
    //                     width: 20,
    //                   ),
    //                   Expanded(
    //                     child: Container(
    //                       child: Text(
    //                         rideDetails.package_description!,
    //                         style: TextStyle(fontSize: 18),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //
    //               SizedBox(
    //                 height: 15,
    //               ),
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Image.asset(
    //                     "images/location_pin.gif",
    //                     height: 36,
    //                     width: 36,
    //                   ),
    //                   SizedBox(
    //                     width: 20,
    //                   ),
    //                   Expanded(
    //                     child: Container(
    //                       child: Text(
    //                         rideDetails.pickup_address!,
    //                         style: TextStyle(fontSize: 18),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               SizedBox(
    //                 height: 15,
    //               ),
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Image.asset(
    //                     "images/desticon.png",
    //                     height: 27,
    //                     width: 27,
    //                   ),
    //                   SizedBox(
    //                     width: 20,
    //                   ),
    //                   Expanded(
    //                     child: Container(
    //                       child: Text(
    //                         rideDetails.dropoff_address!,
    //                         style: TextStyle(fontSize: 18),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               SizedBox(
    //                 height: 20,
    //               ),
    //               Divider(
    //                 thickness: 2,
    //                 color: Colors.black,
    //                 height: 2,
    //               ),
    //               SizedBox(
    //                 height: 8,
    //               ),
    //               Padding(
    //                 padding: EdgeInsets.all(20),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     TextButton(
    //                       style: ButtonStyle(
    //                         backgroundColor:
    //                             MaterialStateProperty.all<Color>(Colors.red),
    //                         // Keep the green background
    //                         foregroundColor:
    //                             MaterialStateProperty.all<Color>(Colors.black),
    //                         // Set text color to black
    //                         textStyle: MaterialStateProperty.all<TextStyle>(
    //                           TextStyle(fontSize: 14.0), // Maintain font size
    //                         ),
    //                         minimumSize: MaterialStateProperty.all<Size>(
    //                             Size(70.0, 40.0)),
    //                         // Increase button width & height
    //                         padding: MaterialStateProperty.all<EdgeInsets>(
    //                             EdgeInsets.symmetric(
    //                                 horizontal:
    //                                     16.0)), // Add some horizontal padding
    //                       ),
    //                       onPressed: () {
    //                         assetsAudioPlayer.stop();
    //                         Navigator.pop(context);
    //                         // Your button press action here
    //                       },
    //                       child: Text(
    //                         "Cancel",
    //                       ),
    //                     ),
    //                     SizedBox(
    //                       width: 70,
    //                     ),
    //                     ElevatedButton(
    //                       style: ButtonStyle(
    //                         backgroundColor:
    //                             MaterialStateProperty.all<Color>(Colors.green),
    //                         // Set background color to red
    //                         foregroundColor:
    //                             MaterialStateProperty.all<Color>(Colors.black),
    //                         // Set text color to black
    //                         textStyle: MaterialStateProperty.all<TextStyle>(
    //                           TextStyle(fontSize: 14.0), // Maintain font size
    //                         ),
    //                         minimumSize: MaterialStateProperty.all<Size>(
    //                             Size(70.0, 40.0)),
    //                         // Increase button width & height
    //                         padding: MaterialStateProperty.all<EdgeInsets>(
    //                             EdgeInsets.symmetric(
    //                                 horizontal:
    //                                     16.0)), // Add some horizontal padding
    //                       ),
    //                       onPressed: () {
    //                         assetsAudioPlayer.stop();
    //                         checkAvailabilityOfRide(context);
    //                         // Your button press action here
    //                       },
    //                       child: Text(
    //                         "Accept",
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               )
    //             ],
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRref.once().then((DatabaseEvent event) {
      Navigator.pop(context);
      DataSnapshot? dataSnapShot = event.snapshot;
      String theRideId = "";
      if (dataSnapShot != null && dataSnapShot.value != null) {
        theRideId = dataSnapShot.value.toString();
      } else {
        displayToastMessage("Ride not exists", context);
      }
      if (theRideId == rideDetails.ride_request_id) {
        rideRequestRref.set("accepted");

        AssistantMethods.disabeLiveLocationUpdate();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NewRequestScreen(rideDetails: rideDetails)));
      } else if (theRideId == "cancelled") {
        displayToastMessage("Ride has been Cancelled", context);
      } else if (theRideId == "timeout") {
        displayToastMessage("Ride Time out", context);
      } else {
        displayToastMessage("Ride not exists", context);
      }
    }).catchError((error) {
      print("Error: $error");
      displayToastMessage("Error occurred: $error", context);
    });
  }
}
