// drivers_information.dart
import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String? name;
  String? phone;
  String? email;
  String? id;
  String? car_color;
  String? car_model;
  String? car_number;
  String? back_id_img;
  String? xgbn66jryGeyLhg1AtCfrRydXOh1;

  Drivers({
    this.name,
    this.phone,
    this.email,
    this.id,
    this.car_color,
    this.car_model,
    this.car_number,
    this.back_id_img,
    this.xgbn66jryGeyLhg1AtCfrRydXOh1,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      phone = values["phoneNumber"] as String?;
      email = values["email"] as String?;
      name = values["name"] as String?;
      back_id_img = values["back_id_img"] as String?;
      //xgbn66jryGeyLhg1AtCfrRydXOh1 = values["xgbn66jryGeyLhg1AtCfrRydXOh1"] as String?;
      Map<dynamic, dynamic>? carDetails = values["car_details"] as Map<dynamic, dynamic>?;

      if (carDetails != null) {
        car_color = carDetails["color"] as String?; // Assuming "color" is used instead of "car_color"
        car_model = carDetails["model"] as String?; // Assuming "model" is used instead of "car_model"
        car_number = carDetails["plateNumber"] as String?; // Assuming "plateNumber" is used instead of "car_number"
      }
    }
  }
}










// import 'package:firebase_database/firebase_database.dart';
//
// class Drivers {
//   String? name;
//   String? phone;
//   String? email;
//   String? id;
//   String? car_color;
//   String? car_model;
//   String? car_number;
//   String? back_id_img; // New attribute
//   String? xgbn66jryGeyLhg1AtCfrRydXOh1; // New attribute
//
//   Drivers({
//     this.name,
//     this.phone,
//     this.email,
//     this.id,
//     this.car_color,
//     this.car_model,
//     this.car_number,
//     this.back_id_img,
//     this.xgbn66jryGeyLhg1AtCfrRydXOh1,
//   });
//
//   Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
//     id = dataSnapshot.key;
//     Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;
//
//     if (values != null) {
//       phone = values["phoneNumber"] as String?; // Assuming "phoneNumber" is used instead of "phone"
//       email = values["email"] as String?;
//       name = values["name"] as String?;
//       back_id_img = values["back_id_img"] as String?; // Extracting "back_id_img"
//       xgbn66jryGeyLhg1AtCfrRydXOh1 = values["xgbn66jryGeyLhg1AtCfrRydXOh1"] as String?; // Extracting "xgbn66jryGeyLhg1AtCfrRydXOh1"
//
//       // Nested properties
//       Map<dynamic, dynamic>? carDetails = values["car_details"] as Map<dynamic, dynamic>?;
//
//       if (carDetails != null) {
//         car_color = carDetails["color"] as String?; // Assuming "color" is used instead of "car_color"
//         car_model = carDetails["model"] as String?; // Assuming "model" is used instead of "car_model"
//         car_number = carDetails["plateNumber"] as String?; // Assuming "plateNumber" is used instead of "car_number"
//       }
//     }
//   }
// }






// import 'package:firebase_database/firebase_database.dart';
//
// class Drivers
// {
//   String? name;
//   String? phone;
//   String? email;
//   String? id;
//   String? car_color;
//   String? car_model;
//   String? car_number;
//   Drivers({
//     this.name,this.phone,this.email,this.id,this.car_color,this.car_number,this.car_model
// });
//
//   Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
//     id = dataSnapshot.key;
//     Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;
//
//     if (values != null) {
//       phone = values["phone"] as String?;
//       email = values["email"] as String?;
//       name = values["name"] as String?;
//
//       // Nested properties
//       Map<dynamic, dynamic>? carDetails = values["car_details"] as Map<dynamic, dynamic>?;
//
//       if (carDetails != null) {
//         car_color = carDetails["car_color"] as String?;
//         car_model = carDetails["car_model"] as String?;
//         car_number = carDetails["car_number"] as String?;
//       }
//     }
//   }
//
//
//
//
//
// }