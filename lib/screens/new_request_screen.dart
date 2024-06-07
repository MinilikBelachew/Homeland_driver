import 'dart:async';

import 'package:driver/config_maps.dart';
import 'package:driver/main.dart';
import 'package:driver/models/ride_details.dart';
import 'package:driver/widgets/collect_Birr_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../assistant/assistant_methods.dart';
import '../assistant/map_kit_assistant.dart';
import '../data_handler/app_data.dart';
import '../tab_pages/earnings_tab.dart';
import '../widgets/progess_dialog.dart';

class NewRequestScreen extends StatefulWidget {
  // NewRequestScreen({super.key});
  final RideDetails rideDetails;
  NewRequestScreen({required this.rideDetails});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController newRideGoogleMapController;

  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCoOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();

  //may be not correct
  //var locationOptions=LocationSettings (accuracy: LocationAccuracy.bestForNavigation);
  var locationOptions =
      LocationSettings(accuracy: LocationAccuracy.bestForNavigation);

  BitmapDescriptor? animatingMarkerIcon;

  Position? myPosition;

  String status = "accepted";
  String? durationRide = "";

  bool isRequestingDirection = false;

  String? btnTitle = "Arrived";
  Color btnColor = Colors.lightBlueAccent;

  Timer? timer;
  int durationCounter = 0;

  @override
  void initState() {
    // TODO: implement initState

    acceptRideRequest();
  }

  createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, myPosition!.latitude, myPosition!.latitude);

      Marker animatingMarker = Marker(
          markerId: MarkerId("animating"),
          position: mPosition,
          icon: animatingMarkerIcon!,
          rotation: rot,
          infoWindow: InfoWindow(title: "CurrentLocation"));

      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.removeWhere((marker) => marker.markerId.value == "animating");

        markerSet.add(animatingMarker);
      });
      oldPos = mPosition;
      updateRideDetails();
      String? rideRequestId = widget.rideDetails.ride_request_id;

      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude!.toString()
      };
      newRequestRref.child(rideRequestId!).child("driver_location").set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    AppData languageProvider = Provider.of<AppData>(context,listen: false);
    var language = languageProvider.isEnglishSelected;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            markers: markerSet,
            circles: circleSet,
            polylines: polyLineSet,
            zoomControlsEnabled: true,
            initialCameraPosition: NewRequestScreen._kGooglePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265;
              });
              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng = widget.rideDetails.pickup;
              await getPlaceDirection(currentLatLng, pickUpLatLng!);
              getLiveLocationUpdates();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ]),
              height: 270,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Column(
                  children: [
                    Text(
                      durationRide!,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Brand-Bold",
                          color: Colors.deepPurpleAccent),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons
                              .local_shipping_outlined, // Material Icon for dropoff
                          color: Colors.green, // Green color for icons
                          size: 24,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            widget.rideDetails.package_description!,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined, // Material Icon for dropoff
                          color: Colors.green, // Green color for icons
                          size: 24,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            widget.rideDetails.pickup_address!,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop, // Material Icon for dropoff
                          color: Colors.green, // Green color for icons
                          size: 24,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            widget.rideDetails.dropoff_address!,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (status == "accepted") {
                            status = "arrived";
                            String? rideRequestId =
                                widget.rideDetails.ride_request_id;

                            newRequestRref
                                .child(rideRequestId!)
                                .child("status")
                                .set(status);
                            setState(() {
                              btnTitle = "Start Journey";
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => ProgressDialog(
                                message: language?"Please Wait":"እባክዎን ይጠብቁ",
                              ),
                            );

                            await getPlaceDirection(widget.rideDetails.pickup!,
                                widget.rideDetails.dropoff!);
                            Navigator.pop(context);
                          } else if (status == "arrived") {
                            status = "onride";
                            String? rideRequestId =
                                widget.rideDetails.ride_request_id;
                            newRequestRref
                                .child(rideRequestId!)
                                .child("status")
                                .set(status);
                            setState(() {
                              btnTitle = "End Journey";
                            });
                            initTimer();
                          } else if (status == "onride") {
                            endTrip();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                btnTitle!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black38),
                              ),
                              Icon(
                                Icons.directions_car,
                                color: Colors.black38,
                                size: 26,
                              )
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.lightBlueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please Wait",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionsDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print(details?.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResult =
        polylinePoints.decodePolyline(details!.encodedPoints!);
    polylineCoOrdinates.clear();

    if (decodePolyLinePointsResult.isNotEmpty) {
      decodePolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCoOrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.red,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polylineCoOrdinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: pickUpLatLng,
        markerId: MarkerId("pickupId"));

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: dropOffLatLng,
        markerId: MarkerId("dropofId"));

    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
    });
    Circle pickupLockCircle = Circle(
        circleId: CircleId("pickupId"),
        fillColor: Colors.green,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 12,
        strokeColor: Colors.greenAccent);
    Circle dropOffLockCircle = Circle(
        circleId: CircleId("dropofId"),
        fillColor: Colors.red,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 12,
        strokeColor: Colors.redAccent);
    setState(() {
      circleSet.add(pickupLockCircle);
      circleSet.add(dropOffLockCircle);
    });
  }

  void acceptRideRequest() {
    String? rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRref.child(rideRequestId!).child("status").set("accepted");
    newRequestRref
        .child(rideRequestId!)
        .child("driver_name")
        .set(driversInformation!.name);

    newRequestRref
        .child(rideRequestId!)
        .child("driver_phone")
        .set(driversInformation!.phone);

    newRequestRref
        .child(rideRequestId!)
        .child("driver_id")
        .set(driversInformation!.id);

    newRequestRref.child(rideRequestId!).child("car_details").set(
        '${driversInformation!.car_color}-${driversInformation!.car_model}');

    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude!.toString()
    };
    newRequestRref.child(rideRequestId).child("driver_location").set(locMap);

    driverRref
        .child(currentfirebaseUser!.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;

      if (myPosition == null) {
        return;
      }
      var posLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);

      LatLng destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickup!;
      } else {
        destinationLatLng = widget.rideDetails.dropoff!;
      }

      var directionDetails =
          await AssistantMethods.obtainPlaceDirectionsDetails(
              posLatLng, destinationLatLng);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);

    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTrip() async {
    timer!.cancel();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait"));

    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
    var directionDetails = await AssistantMethods.obtainPlaceDirectionsDetails(
        widget.rideDetails.pickup!, currentLatLng);
    Navigator.pop(context);

    int fareAmount = AssistantMethods.caculatePrice(directionDetails);

    String? ridequestId = widget.rideDetails.ride_request_id;

    newRequestRref
        .child(ridequestId!)
        .child("fares")
        .set(fareAmount.toString());
    newRequestRref.child(ridequestId!).child("status").set("ended");

    rideStreamSubscription!.cancel();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectBirrDialog(
              paymentMethod: widget.rideDetails.payment_method!,
              fareAmount: fareAmount,
            ));

    saveEarning(fareAmount);

  }

  void saveEarning(int fareAmount) {
    driverRref
        .child(currentfirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot? dataSnapShot = event.snapshot;

      if (dataSnapShot.value != null) {
        double oldEarnings = double.parse(dataSnapShot.value.toString());
        double totalEarning = fareAmount + oldEarnings;

        driverRref
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarning.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();
        driverRref
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      }
    });
  }
}
