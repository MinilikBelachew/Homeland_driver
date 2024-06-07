import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver/screens/history_screen.dart';
import '../screens/chapa_payment_page.dart'; // Import the payment page

class EarningTabPage extends StatefulWidget {
  const EarningTabPage({super.key});

  @override
  _EarningTabPageState createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  double earnings = 0.0;
  int countJourney = 0;
  double amountToPay = 0.0;
  String accountNumber = '';
  bool isEnglishSelected = true; // Assuming default language is English

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String driverId = user.uid;

      _dbRef.child('drivers').child(driverId).onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            earnings = double.tryParse(data['earnings']?.toString() ?? '0.0') ?? 0.0;
            countJourney = (data['history'] != null && data['history'] is Map) ? data['history'].length : 0;
            amountToPay = double.tryParse(data['amountToPay']?.toString() ?? '0.0') ?? 0.0;
            accountNumber = data['accountNumber']?.toString() ?? '';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blueGrey[900]!, Colors.blueGrey[800]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: ListView(
              children: [
                const SizedBox(height: 30.0),
                _buildEarningsCard(),
                const SizedBox(height: 20.0),
                _buildJourneyCard(),
                const SizedBox(height: 20.0),
                _buildAmountToPayCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white.withOpacity(0.20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEnglishSelected ? "Total Earning" : "ጠቅላላ ገቢ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "\ETB${earnings.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.12),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.white, size: 30.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                isEnglishSelected ? "Total Journey" : "ጠቅላላ ጉዞ",
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              countJourney.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountToPayCard() {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(isEnglishSelected ? "Amount to Pay" : "መክፈል የሚገባ ገንዘብ"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEnglishSelected
                        ? "Account Number: $accountNumber\nAmount to Pay: ETB ${amountToPay.toStringAsFixed(2)}"
                        : "የባንክ ሂሳብ ቁጥር: $accountNumber\nመክፈል የሚገባ ገንዘብ: ETB ${amountToPay.toStringAsFixed(2)}",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapaPaymentPage(
                            amountToPay: amountToPay,
                            accountNumber: accountNumber,
                          ),
                        ),
                      );
                    },
                    child: Text(isEnglishSelected ? "Pay with Chapa" : "በ Chapa ክፈል"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(isEnglishSelected ? "OK" : "እሺ"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglishSelected ? "Amount to Pay" : "መክፈል የሚገባ ገንዘብ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isEnglishSelected ? "Account Number" : "የባንክ ሂሳብ ቁጥር",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "ETB ${amountToPay.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    accountNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';





// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:driver/screens/history_screen.dart';
//
// import '../screens/chapa_payment_page.dart';
//  // Import the payment page
//
// class EarningTabPage extends StatefulWidget {
//   const EarningTabPage({super.key});
//
//   @override
//   _EarningTabPageState createState() => _EarningTabPageState();
// }
//
// class _EarningTabPageState extends State<EarningTabPage> {
//   double earnings = 0.0;
//   int countJourney = 0;
//   double amountToPay = 0.0;
//   String accountNumber = '';
//   bool isEnglishSelected = true; // Assuming default language is English
//
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   void fetchData() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       String driverId = user.uid;
//
//       _dbRef.child('drivers').child(driverId).onValue.listen((event) {
//         if (event.snapshot.exists) {
//           final data = event.snapshot.value as Map<dynamic, dynamic>;
//           setState(() {
//             earnings = double.parse(data['earnings'].toString());
//             countJourney = data['history']?.length ?? 0;
//             amountToPay = double.parse(data['amountToPay'].toString());
//             accountNumber = data['accountNumber'].toString();
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.blueGrey[900]!, Colors.blueGrey[800]!],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 30.0),
//               _buildEarningsCard(),
//               const SizedBox(height: 20.0),
//               _buildJourneyCard(),
//               const SizedBox(height: 20.0),
//               _buildAmountToPayCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEarningsCard() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white.withOpacity(0.20),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               isEnglishSelected ? "Total Earning" : "ጠቅላላ ገቢ",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               "\ETB${earnings.toStringAsFixed(2)}",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 30.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildJourneyCard() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => HistoryScreen()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           color: Colors.white.withOpacity(0.12),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.history, color: Colors.white, size: 30.0),
//             const SizedBox(width: 16.0),
//             Expanded(
//               child: Text(
//                 isEnglishSelected ? "Total Journey" : "ጠቅላላ ጉዞ",
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Text(
//               countJourney.toString(),
//               textAlign: TextAlign.end,
//               style: const TextStyle(
//                 fontSize: 18.0,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAmountToPayCard() {
//     return InkWell(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text(isEnglishSelected ? "Amount to Pay" : "መክፈል የሚገባ ገንዘብ"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     isEnglishSelected
//                         ? "Account Number: $accountNumber\nAmount to Pay: ETB ${amountToPay.toStringAsFixed(2)}"
//                         : "የባንክ ሂሳብ ቁጥር: $accountNumber\nመክፈል የሚገባ ገንዘብ: ETB ${amountToPay.toStringAsFixed(2)}",
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChapaPaymentPage(
//                             amountToPay: amountToPay,
//                             accountNumber: accountNumber,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(isEnglishSelected ? "Pay with Chapa" : "በ Chapa ክፈል"),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   child: Text(isEnglishSelected ? "OK" : "እሺ"),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           color: Colors.white.withOpacity(0.20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isEnglishSelected ? "Amount to Pay" : "መክፈል የሚገባ ገንዘብ",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     isEnglishSelected ? "Account Number" : "የባንክ ሂሳብ ቁጥር",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "ETB ${amountToPay.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 30.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     accountNumber,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






//
// import 'package:driver/assistant/assistant_methods.dart';
// import 'package:driver/data_handler/app_data.dart';
// import 'package:driver/screens/history_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class EarningTabPage extends StatelessWidget {
//   const EarningTabPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//
//       children: [
//         Container(
//           color: Colors.black87,
//           width: double.infinity,
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 70),
//             child: Column(
//               children: [
//                 Text("Total Earning", style: TextStyle(color: Colors.white),),
//                 Text("\$${Provider
//                     .of<AppData>(context, listen: false)
//                     .earnings}", style: TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30),)
//               ],
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             //AssistantMethods.retriveHistoryInfo(context);
//             Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryScreen()));
//
//             // Implement your button action here
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
//             child: Row(
//               children: [
//                 Image.asset(
//                   "images/car_ios.png",
//                   width: 70.0,
//                 ),
//                 const SizedBox(width: 16.0),
//                 Text(
//                   "Total Journey",
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     color: Colors.black, // Dim white color for text
//                   ),
//                 ),
//                  Expanded(
//                   child: Text(
//                     Provider.of<AppData>(context,listen: false).countJourney.toString(),
//                     textAlign: TextAlign.end,
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       color: Colors.black, // Dim white color for text
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             foregroundColor: Colors.black, backgroundColor: Colors.white.withOpacity(0.12), // Text color for pressed state
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0), // Rectangular button with rounded corners
//             ),
//             shadowColor: Colors.black.withOpacity(0.5), // Shadow color
//             elevation: 4.0, // Shadow elevation
//           ),
//         )
//
//
//
//       ],
//     );
//   }
// }
