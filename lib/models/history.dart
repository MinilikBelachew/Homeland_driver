import 'package:firebase_database/firebase_database.dart';

class History {
  String? paymentMethod;
  String? createdAt;
  String? status;
  String? fares;
  String? dropOff;
  String? pickUp;

  History({
    this.dropOff,
    this.paymentMethod,
    this.status,
    this.pickUp,
    this.createdAt,
    this.fares,
  });

 History.fromSnapshot(DataSnapshot snapshot) {
    // Cast to Map<String, dynamic> for type safety
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      paymentMethod = data["payment_method"]?.toString();
      createdAt = data["created_at"]?.toString();
      status = data["status"]?.toString();
      fares = data["fares"]?.toString();
      dropOff = data["dropoff_address"]?.toString();
      pickUp = data["pickup_address"]?.toString();
    } else {
      // Handle the case where the data is not a map (e.g., print a warning)
      print(
          "WARNING: Data in Firebase for History is not a Map. Data not assigned.");
    }

  }
}
