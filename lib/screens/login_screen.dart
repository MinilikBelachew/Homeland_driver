import 'package:driver/config_maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver/main.dart';
import 'package:driver/screens/main_screen.dart';
import 'package:driver/screens/signup_screen.dart';
import 'package:driver/widgets/progess_dialog.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image(
                image: AssetImage("images/home2.jpg"),
                width: 350,
                height: 350,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Log in As a Driver",
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
                    SizedBox(
                      height: 1,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          )),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          )),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor:
                            Colors.lightBlueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 50)),

                        onPressed: () {
                          if (!emailTextEditingController.text.contains("@")) {
                            displayToastMessage(
                                "Email Address Is not Valid", context);
                          }
                          else if (passwordTextEditingController.text.isEmpty) {
                            displayToastMessage("Password is not correct",
                                context);
                          }
                          else {
                            loginAndAuthenticationUser(context);
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Signatra"
                          ),
                        ))
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder:(contex) => const ForgotPasswordScreen()));


                },
                child: Text("Forgot Password?", style: TextStyle(
                    color: Colors.blue
                ),),
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text("Don't have An Account?", style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15
                  ),),
                  const SizedBox(width: 5,),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, SignupScreen.idScreen, (route) => false);
                      // Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));


                    },
                    child: Text("Register", style: TextStyle(
                        fontSize: 15,
                        color: Colors.lightBlue
                    ),),

                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  void loginAndAuthenticationUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Authenticating, please wait...");
      },
    );

    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        final snapshot = await driverRref.child(user.uid).once();

        if (snapshot.snapshot.value != null) {
          currentfirebaseUser= firebaseUser;

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are logged in", context);
        } else {
          Navigator.pop(context);
          await _firebaseAuth.signOut();
          displayToastMessage(
              "No record exists for this account. Please create a new Account",
              context);
        }
      } else {
        Navigator.pop(context);
        displayToastMessage("Error Occurred", context);
      }
    } catch (error) {
      Navigator.pop(context);
      displayToastMessage("Error: $error", context);
    }
  }
}