// import 'package:driver/config_maps.dart';
// import 'package:driver/models/drivers.dart';
// import 'package:driver/screens/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// class ProfileTabPage extends StatefulWidget {
//   const ProfileTabPage({Key? key}) : super(key: key);
//
//   @override
//   State<ProfileTabPage> createState() => _ProfileTabPageState();
// }
//
// class _ProfileTabPageState extends State<ProfileTabPage> {
//   Drivers? driversInformation;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDriverInformation();
//   }
//
//   void fetchDriverInformation() async {
//     String userId = FirebaseAuth.instance.currentUser!.uid;
//     DatabaseReference driverRef =
//         FirebaseDatabase.instance.ref().child('drivers').child(userId);
//
//     final snapshot = await driverRef.get();
//     if (snapshot.exists) {
//       setState(() {
//         driversInformation = Drivers.fromSnapshot(snapshot);
//       });
//     } else {
//       setState(() {
//         driversInformation = null;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final driverInfo = driversInformation;
//
//     if (driverInfo == null) {
//       return Scaffold(
//         backgroundColor: Theme.of(context).backgroundColor, // Use theme color
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Profile'), // Clear and concise title
//         backgroundColor: Theme.of(context).primaryColor, // Use theme color
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_rounded), // Modern back icon
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: SingleChildScrollView(
//             // Allow scrolling if content overflows
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       driverInfo.name ?? 'No Name',
//                       style: TextStyle(
//                         fontSize: 24.0, // Adjust font size as needed
//                         color: Theme.of(context)
//                             .textTheme
//                             .headline6!
//                             .color, // Use theme color
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Signatra",
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.edit,
//                           color: Colors.white70), // Maintain edit icon color
//                       onPressed: () => _handleNameUpdate(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10.0), // Spacing between name and title
//                 Text(
//                   'Driver',
//                   style: TextStyle(
//                     fontSize: 18.0, // Adjust font size as needed
//                     color: Colors.grey[700], // Consider a lighter color
//                     fontWeight: FontWeight.w500, // Semi-bold for emphasis
//                   ),
//                 ),
//                 const SizedBox(height: 20.0), // Spacing before info cards
//                 DriverInfoCard(
//                   text: driverInfo.phone ?? 'No Phone',
//                   icon: Icons.phone,
//                   onPressed: () => _handlePhoneUpdate(context),
//                 ),
//                 const SizedBox(height: 10.0), // Spacing between cards
//                 DriverInfoCard(
//                   text: driverInfo.email ?? 'No Email',
//                   icon: Icons.email,
//                   onPressed: () => _handleEmailUpdate(context),
//                 ),
//                 const SizedBox(height: 10.0), // Spacing between cards
//                 DriverInfoCard(
//                   text:
//                       "${driverInfo.car_color ?? ''} ${driverInfo.car_model ?? ''} ${driverInfo.car_number ?? ''}"
//                           .trim(),
//                   icon: Icons.car_rental,
//                   onPressed: () => _handleCarDetailsUpdate(context),
//                 ),
//                 const SizedBox(height: 40.0), // Spacing before sign out button
//                 ElevatedButton(
//                   onPressed: () => _handleSignOut(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red[400], // Adjust color as needed
//
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12.0, horizontal: 24.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: Text(
//                     "Sign Out",
//                     style: const TextStyle(
//                         fontSize: 18.0, fontFamily: "Brand-Bold"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handlePhoneUpdate(BuildContext context) {
//     _showUpdateDialog(
//         context, 'Phone Number', driversInformation!.phone ?? 'No Phone',
//         (newValue) {
//       _updateField('phoneNumber', newValue);
//     });
//   }
//
//   void _handleEmailUpdate(BuildContext context) {
//     _showUpdateDialog(context, 'Email', driversInformation!.email ?? 'No Email',
//         (newValue) {
//       _updateField('email', newValue);
//     });
//   }
//
//   void _handleNameUpdate(BuildContext context) {
//     _showUpdateDialog(context, 'Name', driversInformation!.name ?? 'No Name',
//         (newValue) {
//       _updateField('name', newValue);
//     });
//   }
//
//   void _handleCarDetailsUpdate(BuildContext context) {
//     // Implement functionality to update car details
//     // Use a modal or separate screen for editing
//     print("Update car details");
//   }
//
//   void _handleSignOut(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushNamedAndRemoveUntil(
//         context, LoginScreen.idScreen, (route) => false);
//   }
//
//   void _showUpdateDialog(BuildContext context, String field,
//       String currentValue, Function(String) onUpdate) {
//     TextEditingController controller =
//         TextEditingController(text: currentValue);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Update $field'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: 'Enter new $field',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 onUpdate(controller.text);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Update'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _updateField(String field, String newValue) async {
//     String userId = FirebaseAuth.instance.currentUser!.uid;
//
//     DatabaseReference userRef =
//         FirebaseDatabase.instance.ref().child('drivers/$userId');
//
//     await userRef.update({
//       field: newValue,
//     });
//
//     // Refresh the information locally
//     setState(() {
//       if (field == 'name') {
//         driversInformation!.name = newValue;
//       } else if (field == 'phoneNumber') {
//         driversInformation!.phone = newValue;
//       } else if (field == 'email') {
//         driversInformation!.email = newValue;
//       }
//     });
//   }
// }
//
// class DriverInfoCard extends StatelessWidget {
//   final String text;
//   final IconData icon;
//   final VoidCallback onPressed;
//
//   const DriverInfoCard(
//       {required this.text, required this.icon, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Card(
//         color: Colors.white,
//         margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
//         child: ListTile(
//           leading: Icon(icon,
//               color: Theme.of(context).primaryColor), // Use theme color
//           title: Text(
//             text,
//             style: TextStyle(
//               color: Theme.of(context)
//                   .textTheme
//                   .bodyText1!
//                   .color, // Use theme color
//               fontSize: 16.0,
//               fontFamily: "Brand-Bold",
//             ),
//           ),
//           trailing: Icon(Icons.arrow_forward_ios_rounded), // Add forward arrow
//         ),
//       ),
//     );
//   }
// }

// profile_tab.dart

import 'package:driver/config_maps.dart';
import 'package:driver/models/drivers.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_handler/app_data.dart';


class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  void initState() {
    super.initState();
    fetchDriverInformation();
  }

  void fetchDriverInformation() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers').child(userId);

    driverRef.once().then((DatabaseEvent snapshotEvent) {
      final snapshot = snapshotEvent.snapshot;
      if (snapshot.exists) {
        setState(() {
          driversInformation = Drivers.fromSnapshot(snapshot);
        });
      } else {
        setState(() {
          driversInformation = null;
        });
      }
    }).catchError((error) {
      print("Error fetching driver information: $error");
      setState(() {
        driversInformation = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;
    final driverInfo = driversInformation;

    if (driverInfo == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F1F1F),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      //backgroundColor: const Color(0xFF1F1F1F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[800]!], // Adjust gradient colors for preference
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _handleNameUpdate(context),
                  child: Column(
                    children: [
                      Text(
                        driverInfo.name ?? 'No Name',
                        style: TextStyle(
                          fontSize: 36.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Signatra",
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.white70),
                    ],
                  ),
                ),
                Text(
                  title +  " Driver",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Signatra",
                  ),
                ),
                const Divider(color: Colors.white54),
                const SizedBox(height: 20.0),
                InfoCard(
                  text: driverInfo.phone ?? 'No Phone',
                  icon: Icons.phone,
                  onPressed: () => _handlePhoneUpdate(context),
                ),
                const SizedBox(height: 10.0),
                InfoCard(
                  text: driverInfo.email ?? 'No Email',
                  icon: Icons.email,
                  onPressed: () => _handleEmailUpdate(context),
                ),
                const SizedBox(height: 10.0),
                InfoCard(
                  text: "${driverInfo.car_color ?? ''} ${driverInfo.car_model ?? ''} ${driverInfo.car_number ?? ''}".trim(),
                  icon: Icons.car_rental,
                  onPressed: () => _handleCarDetailsUpdate(context),
                ),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: () => _handleSignOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    language?
                    "Sign Out":"ዛግተ ውጣ",
                    style: const TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePhoneUpdate(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context,listen: false);
    var language = languageProvider.isEnglishSelected;
    _showUpdateDialog(context, 'Phone Number', driversInformation!.phone ?? 'No Phone', (newValue) {
      _updateField('phoneNumber', newValue);
    });
  }

  void _handleEmailUpdate(BuildContext context) {
    _showUpdateDialog(context, 'Email', driversInformation!.email ?? 'No Email', (newValue) {
      _updateField('email', newValue);
    });
  }

  void _handleNameUpdate(BuildContext context) {
    _showUpdateDialog(context, 'Name', driversInformation!.name ?? 'No Name', (newValue) {
      _updateField('name', newValue);
    });
  }

  void _handleCarDetailsUpdate(BuildContext context) {

    displayToastMessage("you can not edit car informations", context);
    // Implement functionality to update car details
    // Use a modal or separate screen for editing
    print("Update car details");
  }

  void _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
  }

  void _showUpdateDialog(BuildContext context, String field, String currentValue, Function(String) onUpdate) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onUpdate(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateField(String field, String newValue) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('drivers/$userId');

    await userRef.update({
      field: newValue,
    });

    // Refresh the information locally
    setState(() {
      if (field == 'name') {
        driversInformation!.name = newValue;
      } else if (field == 'phoneNumber') {
        driversInformation!.phone = newValue;
      } else if (field == 'email') {
        driversInformation!.email = newValue;
      }
    });
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const InfoCard({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use theme color
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        boxShadow: [
          BoxShadow( // Add subtle shadow
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align horizontally
          children: [
            Row( // Align icon and text vertically
              children: [
                Icon(icon, color: Theme.of(context).primaryColor), // Use theme color
                const SizedBox(width: 10.0), // Spacing between icon and text
                Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color, // Use theme color
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            IconButton( // Edit button
              icon: Icon(Icons.edit_rounded),
              color: Theme.of(context).primaryColor, // Use theme color
              onPressed: onPressed,
            ),            ],
        ),
      ),
    );
  }
}

