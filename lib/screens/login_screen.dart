import 'package:driver/config_maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver/main.dart';
import 'package:driver/screens/main_screen.dart';
import 'package:driver/widgets/progess_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../data_handler/app_data.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = "login";

  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool _showPassword = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int loginAttempts = 0;
  DateTime? nextLoginTime;
  Timer? _lockoutTimer;
  String _lockoutTimeDisplay = '';
  final storage = FlutterSecureStorage();

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void startLockoutTimer() {
    const oneSec = const Duration(seconds: 1);
    _lockoutTimer = Timer.periodic(oneSec, (Timer timer) {
      if (nextLoginTime == null || DateTime.now().isAfter(nextLoginTime!)) {
        setState(() {
          _lockoutTimeDisplay = '';
          timer.cancel();
        });
      } else {
        final remaining = nextLoginTime!.difference(DateTime.now());
        setState(() {
          _lockoutTimeDisplay = 'Please wait ${remaining.inSeconds}s before trying again';
        });
      }
    });
  }

  void setLockoutTime() {
    int lockoutDuration = 30;
    if (loginAttempts >= 10) {
      lockoutDuration = 60;
    } else if (loginAttempts >= 5) {
      lockoutDuration = 30;
    }
    nextLoginTime = DateTime.now().add(Duration(seconds: lockoutDuration));
    startLockoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;

    return SafeArea(
        child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.lightBlue.shade100,
              Colors.lightBlue.shade300,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
              children: [
          Image(
          image: AssetImage("images/home.png"),
          width: 300,
          height: 300,
          color: Colors.teal,
          alignment: Alignment.center,
        ),
        SizedBox(height: 15),
        Text(
          language ? "Login" : "ግባ",
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Brand Bold",
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 1),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: language ? "Email" : "ኢሜይል",
                  labelStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordTextEditingController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  labelText: language ? "Password" : "የይለፍ ቃል",
                  labelStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              if (_lockoutTimeDisplay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _lockoutTimeDisplay,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.lightBlueAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (nextLoginTime != null && DateTime.now().isBefore(nextLoginTime!)) {
                    displayToastMessage(
                        language
                            ? "Too many login attempts. Please try again later."
                            : "እጅግ ብዙ ግባ ሙከራዎች. እባክዎን በኋላ ደግመው ይሞክሩ.",
                        context);
                    return;
                  }

                  if (!isValidEmail(emailTextEditingController.text)) {
                    displayToastMessage(
                        language
                            ? "Please enter a valid email address"
                            : "እባክህን ትክክለኛ ኢሜይል አስገባ",
                        context);
                  } else if (!isValidPassword(passwordTextEditingController.text)) {
                    displayToastMessage(
                        language
                            ? "Password must be at least 6 characters long"
                            : "የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት።",
                        context);
                  } else {
                    // Check connectivity
                    var connectivityResult = await (Connectivity().checkConnectivity());
                    if (connectivityResult == ConnectivityResult.none) {
                      // Attempt offline login if no internet connection
                      final email = emailTextEditingController.text.trim();
                      final password = passwordTextEditingController.text.trim();
                      final offlineLoginSuccess = await verifyCredentials(email, password);

                      if (offlineLoginSuccess) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, MainScreen.idScreen, (route) => false);
                        displayToastMessage("Offline login successful", context);
                      } else {
                        displayToastMessage(
                            language
                                ? "No internet connection and offline login failed"
                                : "የበይነመረብ ግንኙነት የለም እና ኦፍላይን መግባት አልተሳካም",
                            context);
                      }
                    } else {
                      // Attempt online login if internet connection is available
                      loginAndAuthenticationUser(context);
                    }
                  }
                },
                child: Text(
                  language ? "Login" : "ግባ",
                  style: TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder:(context) => ForgotPasswordScreen()));
        },
          child: Text(
            language ? "Forgot Password?" : "መክፈቻ ቁልፉን ረሳኽው?",
            style: TextStyle(color: Colors.blue),
          ),
        ),
              ],
          ),
        ),
        ),
        ),
    );
  }

  Future<void> storeCredentials(String email, String password) async {
    final salt = utf8.encode(email); // using email as salt for simplicity
    final key = utf8.encode(password);
    final hmacSha256 = Hmac(sha256, salt); // HMAC-SHA256
    final digest = hmacSha256.convert(key);

    // Store email and hashed password
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: digest.toString());
  }

  Future<bool> verifyCredentials(String email, String password) async {
    final storedEmail = await storage.read(key: 'email');
    final storedHashedPassword = await storage.read(key: 'password');

    if (storedEmail == null || storedHashedPassword == null) {
      return false;
    }

    // Hash the input password with the stored salt (email in this case)
    final salt = utf8.encode(email);
    final key = utf8.encode(password);
    final hmacSha256 = Hmac(sha256, salt);
    final digest = hmacSha256.convert(key);

    return storedEmail == email && storedHashedPassword == digest.toString();
  }

  void loginAndAuthenticationUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Authenticating, please wait...");
      },
    );

    try {
      final String email = emailTextEditingController.text.trim();
      final String password = passwordTextEditingController.text.trim();

      // Firebase expects the original password
      final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        final snapshot = await driverRref.child(user.uid).once();

        if (snapshot.snapshot.value != null) {
          currentfirebaseUser = user;

          // Store credentials securely
          await storeCredentials(email, password);

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are logged in", context);
        } else {
          Navigator.pop(context);
          await _firebaseAuth.signOut();
          displayToastMessage(
              "No record exists for this account. Please sign up first.",
              context);
        }
      } else {
        Navigator.pop(context);
        displayToastMessage(
            "An unexpected error occurred. Please try again.", context);
      }
    } catch (error) {
      Navigator.pop(context);
      loginAttempts++;
      if (loginAttempts >= 5) {
        setLockoutTime();
      }
      handleFirebaseAuthError(error, context);
    }
  }

  void handleFirebaseAuthError(dynamic error, BuildContext context) {
    String message;
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'user-disabled':
          message = "This user has been disabled. Please contact support.";
          break;
        case 'user-not-found':
          message = "No user found with this email. Please sign up.";
          break;
        case 'wrong-password':
          message = "Incorrect password. Please try again.";
          break;
        default:
          message = "An unexpected error occurred. Please try again.";
      }
    } else if (error.toString().contains('network_error')) {
      message = "Network error occurred. Please check your connection and try again.";
    } else {
      message = "An unexpected error occurred. Please try again.";
    }
    displayToastMessage(message, context);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  void displayToastMessage(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}





// import 'package:driver/config_maps.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:driver/main.dart';
// import 'package:driver/screens/forgot_password.dart';
// import 'package:driver/screens/main_screen.dart';
// import 'package:driver/widgets/progess_dialog.dart';
// import 'package:crypto/crypto.dart'; // For hashing
// import 'package:provider/provider.dart';
// import 'dart:convert';
//
// import '../data_handler/app_data.dart'; // For utf8.encode
//
// class LoginScreen extends StatefulWidget {
//   static const String idScreen = "login";
//
//   LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController passwordTextEditingController = TextEditingController();
//   bool _showPassword = false;
//
//   @override
//   Widget build(BuildContext context) {
//     AppData languageProvider = Provider.of<AppData>(context);
//     var language = languageProvider.isEnglishSelected;
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.white,
//                 Colors.lightBlue.shade100,
//                 Colors.lightBlue.shade300,
//               ],
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image(
//                   image: AssetImage("images/home.png"),
//                   width: 300,
//                   height: 300,
//                   color: Colors.teal,
//                   alignment: Alignment.center,
//                 ),
//                 SizedBox(height: 15),
//                 Text( language ?
//                   "Login ":"ግባ",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontFamily: "Brand Bold",
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 1),
//                       TextField(
//                         controller: emailTextEditingController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText:language? "Email":"ኢሜይል",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.black, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 15),
//                       TextField(
//                         controller: passwordTextEditingController,
//                         obscureText: !_showPassword,
//                         decoration: InputDecoration(
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _showPassword ? Icons.visibility_off : Icons.visibility,
//                             ),
//                             onPressed: () =>
//                                 setState(() => _showPassword = !_showPassword),
//                           ),
//                           labelText: language?"Password":"የይለፍ ቃል",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 1.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.black87,
//                           backgroundColor: Colors.lightBlueAccent,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           minimumSize: const Size(double.infinity, 50),
//                         ),
//                         onPressed: () {
//                           if (!isValidEmail(emailTextEditingController.text)) {
//                             displayToastMessage( language?
//                                 "Please enter a valid email address":"እባክህን ትክክለኛ ኢሜል አስገባ", context);
//                           } else if (!isValidPassword(passwordTextEditingController.text)) {
//                             displayToastMessage(language? "Password must be at least 6 characters long":"የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት።", context);
//                           } else {
//                             loginAndAuthenticationUser(context);
//                           }
//                         },
//                         child: Text(
//                           language?
//                           "Login":"ግባ",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontFamily: "Brand-Bold"
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                      Navigator.push(context, MaterialPageRoute(builder:(contex) =>  ForgotPasswordScreen()));
//                   },
//                   child: Text( language?"Forgot Password?":"መክፈቻ ቁልፉን ረሳኽው?", style: TextStyle(
//                       color: Colors.blue
//                   ),),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   void loginAndAuthenticationUser(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return ProgressDialog(message: "Authenticating, please wait...");
//       },
//     );
//
//     try {
//       final String email = emailTextEditingController.text.trim();
//       final String password = passwordTextEditingController.text.trim();
//
//       // Example hashing of password (although Firebase handles hashing securely)
//       final bytes = utf8.encode(password);
//       final hashedPassword = sha256.convert(bytes).toString();
//
//       final UserCredential userCredential = await _firebaseAuth
//           .signInWithEmailAndPassword(
//         email: email,
//         password: password, // Firebase expects the original password
//       );
//
//       final User? user = userCredential.user;
//
//       if (user != null) {
//         final snapshot = await driverRref.child(user.uid).once();
//
//         if (snapshot.snapshot.value != null) {
//           currentfirebaseUser = firebaseUser;
//
//           Navigator.pushNamedAndRemoveUntil(
//               context, MainScreen.idScreen, (route) => false);
//           displayToastMessage("You are logged in", context);
//         } else {
//           Navigator.pop(context);
//           await _firebaseAuth.signOut();
//           displayToastMessage(
//               "No record exists for this account. Please sign up first.",
//               context);
//         }
//       } else {
//         Navigator.pop(context);
//         displayToastMessage("An unexpected error occurred. Please try again.", context);
//       }
//     } catch (error) {
//       Navigator.pop(context);
//       handleFirebaseAuthError(error, context);
//     }
//   }
//
//   void handleFirebaseAuthError(dynamic error, BuildContext context) {
//     String message;
//     if (error is FirebaseAuthException) {
//       switch (error.code) {
//         case 'invalid-email':
//           message = "The email address is not valid.";
//           break;
//         case 'user-disabled':
//           message = "This user has been disabled. Please contact support.";
//           break;
//         case 'user-not-found':
//           message = "No user found with this email. Please sign up.";
//           break;
//         case 'wrong-password':
//           message = "Incorrect password. Please try again.";
//           break;
//         default:
//           message = "An unexpected error occurred. Please try again.";
//       }
//     } else {
//       message = "An unexpected error occurred. Please try again.";
//     }
//     displayToastMessage(message, context);
//   }
//
//   bool isValidEmail(String email) {
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     return emailRegex.hasMatch(email);
//   }
//
//   bool isValidPassword(String password) {
//     return password.length >= 6;
//   }
//
//   void displayToastMessage(String message, BuildContext context) {
//     final snackBar = SnackBar(content: Text(message));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }


//
//
//
//
// import 'package:driver/config_maps.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:driver/main.dart';
// import 'package:driver/screens/main_screen.dart';
// import 'package:driver/screens/signup_screen.dart';
// import 'package:driver/widgets/progess_dialog.dart';
//
// class LoginScreen extends StatefulWidget {
//   static const String idScreen = "login";
//
//   LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailTextEditingController = TextEditingController();
//
//   TextEditingController passwordTextEditingController = TextEditingController();
//
//   bool _showPassword = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child:
//       Scaffold(
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.tealAccent.shade100],
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image(
//                   image: AssetImage("images/home.png"),
//                   width: 300,
//                   height: 300,
//                   color: Colors.teal,
//                   alignment: Alignment.center,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text(
//                   "Login as a Driver",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontFamily: "Brand Bold",
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 1,
//                       ),
//                       TextField(
//                         controller: emailTextEditingController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//
//                           labelText: "Email",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.black, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       TextField(
//
//                         controller: passwordTextEditingController,
//                         obscureText: !_showPassword,
//                         decoration: InputDecoration(
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _showPassword
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                             ),
//                             onPressed: () =>
//
//                                 setState(() => _showPassword = !_showPassword),
//                           ),
//                           labelText: "password",
//                           labelStyle: TextStyle(
//                             color: Colors.grey.shade400, // Lighter grey for better contrast
//                             fontSize: 14, // Increase label size for readability
//                           ),
//                           enabledBorder: OutlineInputBorder( // Style the border
//                             borderRadius: BorderRadius.circular(10.0), // Rounded corners
//                             borderSide: BorderSide(color: Colors.blue, width: 1.0), // Light border
//                           ),
//                           focusedBorder: OutlineInputBorder( // Style the border when focused
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(color: Colors.blue, width: 2.0), // Blue border on focus
//                           ),
//                         ),
//                         style: TextStyle(fontSize: 16), // Increase text size for better readability
//                       ),
//                       SizedBox(height: 10,),
//                       ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.black87,
//                               backgroundColor:
//                               Colors.lightBlueAccent,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                               minimumSize: const Size(double.infinity, 50)),
//
//                           onPressed: () {
//                             if (!emailTextEditingController.text.contains("@")) {
//                               displayToastMessage(
//                                   "Email Address Is not Valid", context);
//                             }
//                             else if (passwordTextEditingController.text.isEmpty) {
//                               displayToastMessage("Password is not correct",
//                                   context);
//                             }
//                             else {
//                               loginAndAuthenticationUser(context);
//                             }
//                           },
//                           child: Text(
//                             "Login",
//                             style: TextStyle(
//                                 fontSize: 18,
//                                 fontFamily: "Brand-Bold"
//                             ),
//                           ))
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // Navigator.push(context, MaterialPageRoute(builder:(contex) => const ForgotPasswordScreen()));
//
//
//                   },
//                   child: Text("Forgot Password?", style: TextStyle(
//                       color: Colors.blue
//                   ),),
//                 ),
//                 // const SizedBox(height: 30,),
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment.center,
//                 //
//                 //   children: [
//                 //     const Text("Don't have An Account?", style: TextStyle(
//                 //         color: Colors.grey,
//                 //         fontSize: 15
//                 //     ),),
//                 //     const SizedBox(width: 5,),
//                 //     GestureDetector(
//                 //       onTap: () {
//                 //         Navigator.pushNamedAndRemoveUntil(
//                 //             context, SignupScreen.idScreen, (route) => false);
//                 //         // Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));
//                 //
//                 //
//                 //       },
//                 //       child: Text("Register", style: TextStyle(
//                 //           fontSize: 15,
//                 //           color: Colors.lightBlue
//                 //       ),),
//                 //
//                 //     )
//                 //   ],
//                 // )
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   void loginAndAuthenticationUser(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return ProgressDialog(message: "Authenticating, please wait...");
//       },
//     );
//
//     try {
//       final UserCredential userCredential = await _firebaseAuth
//           .signInWithEmailAndPassword(
//         email: emailTextEditingController.text.trim(),
//         password: passwordTextEditingController.text.trim(),
//       );
//
//
//       final User? user = userCredential.user;
//
//       if (user != null) {
//         final snapshot = await driverRref.child(user.uid).once();
//
//         if (snapshot.snapshot.value != null) {
//           currentfirebaseUser= firebaseUser;
//
//           Navigator.pushNamedAndRemoveUntil(
//               context, MainScreen.idScreen, (route) => false);
//           displayToastMessage("You are logged in", context);
//         } else {
//           Navigator.pop(context);
//           await _firebaseAuth.signOut();
//           displayToastMessage(
//               "No record exists for this account.",
//               context);
//         }
//       } else {
//         Navigator.pop(context);
//         displayToastMessage("Error Occurred", context);
//       }
//     } catch (error) {
//       Navigator.pop(context);
//       displayToastMessage("Error: $error", context);
//     }
//   }
// }