import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:driver/config_maps.dart';
import 'package:driver/screens/car_info_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:driver/data_handler/app_data.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/main_screen.dart';
import 'package:driver/screens/signup_screen.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:driver/data_handler/app_data.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBJ0H1IflNFaMKt7Pnfu4uatPPQ4XvVnrA",
          appId: "1:771185889083:android:9f667313b7cf6bab12b11e",
          messagingSenderId: "771185889083",
          projectId: "homeland-95f19",
          databaseURL:"https://homeland-95f19-default-rtdb.firebaseio.com/"
      )
  );
  currentfirebaseUser= FirebaseAuth.instance.currentUser;
  Chapa.configure(privateKey: "CHASECK_TEST-xMHE3ZOi6SWCWdERIqabPLsRYwCTs9da");

  runApp(const MyApp());
}

DatabaseReference useRref=FirebaseDatabase.instance.ref().child("users");
DatabaseReference driverRref=FirebaseDatabase.instance.ref().child("drivers");
DatabaseReference newRequestRref=FirebaseDatabase.instance.ref().child("Ride Request");

DatabaseReference rideRequestRref=FirebaseDatabase.instance.ref().child("drivers").child(currentfirebaseUser!.uid).child("newRide");


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) =>AppData(),
      child: Consumer<AppData>(
        builder: (context, appData, _) {
          return MaterialApp(
            title: 'Driver',
            theme: ThemeData.light(),
            darkTheme:
            ThemeData.dark().copyWith(
              primaryColor: Colors.lightBlue,
              scaffoldBackgroundColor: Colors.grey[900], // Darker background color
              appBarTheme: AppBarTheme(
                color: Colors.grey[800], // Darker app bar color
              ), // Button color
              iconTheme: IconThemeData(color: Colors.white), // Icon color
              dividerColor: Colors.grey[600], // Divider color
              cardTheme: CardTheme(
                color: Colors.grey[800], // Card color
                elevation: 4, // Elevation color
              ),
              errorColor: Colors.redAccent, // Error color
              hintColor: Colors.amber, // Accent color
              textTheme: TextTheme(
                bodyText1: TextStyle(color: Colors.white), // Text color
                // You can also customize other text styles like headline, subtitle etc.
              ),
            ),
            themeMode: appData.getThemeMode(),
            initialRoute: LoginScreen.idScreen,
            routes: {
              SignupScreen.idScreen: (context) => SignupScreen(),
              LoginScreen.idScreen: (context) => LoginScreen(),
              MainScreen.idScreen: (context) => MainScreen(),
              CarInfoScreen.idScreen: (context) => CarInfoScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
//     return ChangeNotifierProvider(
//       create: (context) =>AppData(),
//       child: MaterialApp(
//         title: 'Driver',
//           theme: ThemeData.light(), // Default light theme
//           darkTheme: ThemeData.dark(), // Default dark theme
//           themeMode: AppData.getThemeMode(),
//         initialRoute: LoginScreen.idScreen,
//         //initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen:LoginScreen.idScreen,
//         routes: {
//          SignupScreen.idScreen:(context) => SignupScreen(),
//           LoginScreen.idScreen:(context) => LoginScreen(),
//           MainScreen.idScreen:(context)=> MainScreen(),
//           CarInfoScreen.idScreen:(context)=> CarInfoScreen()
//
//         },
//
//         debugShowCheckedModeBanner: false
//
//       ),
//     );
//   }
// }


