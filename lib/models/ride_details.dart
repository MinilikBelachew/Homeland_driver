import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
  String? pickup_address;
  String? dropoff_address;
  LatLng? pickup;
  LatLng? dropoff;
  String? ride_request_id;
  String? payment_method;
  String? rider_name;
  String? rider_phone;
  String? package_description;

  RideDetails(
      {this.dropoff,
      this.dropoff_address,
      this.payment_method,
      this.pickup,
      this.pickup_address,
      this.ride_request_id,
      this.rider_name,
      this.rider_phone,
      this.package_description
      });
}
