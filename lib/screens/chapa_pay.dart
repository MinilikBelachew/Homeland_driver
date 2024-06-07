import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // If you need Cupertino widgets for iOS

class ChapaPayment extends StatefulWidget {
  const ChapaPayment({super.key, required this.title, required this.fareAmount});
  static const String idScreen = "chapa";
  final String title;
  final double fareAmount;

  @override
  State<ChapaPayment> createState() => _ChapaPaymentState();
}

class _ChapaPaymentState extends State<ChapaPayment> {

  Future<void> verify() async {
    Map<String, dynamic> verificationResult =
    await Chapa.getInstance.verifyPayment(
      txRef: TxRefRandomGenerator.gettxRef,
    );
    if (kDebugMode) {
      print(verificationResult);
    }
  }

  Future<void> pay(String payamont) async {
    try {
      String txRef = TxRefRandomGenerator.generate(prefix: 'linat');
      String storedTxRef = TxRefRandomGenerator.gettxRef;

      if (kDebugMode) {
        print('Generated TxRef: $txRef');
        print('Stored TxRef: $storedTxRef');
      }
      await Chapa.getInstance.startPayment(
        context: context,
        onInAppPaymentSuccess: (successMsg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Successful: $successMsg')),
          );
        },
        onInAppPaymentError: (errorMsg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Error: $errorMsg')),

          );
          print("" + errorMsg);
        },
        amount: payamont,
        currency: 'ETB',
        txRef: storedTxRef,

      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Exception: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey, // Make app bar transparent
        elevation: 0.0, // Remove app bar shadow
      ),
      body: Container(
        color: const Color(0xFFF2F2F2), // Set background color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Pay to Homeland',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount to Pay:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${widget.fareAmount} ETB',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible( // Wrap buttons with Flexible for adaptive sizing
                    child: ElevatedButton(
                      onPressed: () => pay(widget.fareAmount.toString()),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment),
                            SizedBox(width: 4.0), // Add a small space between icon and text
                            Text('Pay Now'),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853), // Use a vibrant green color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.0),
                  Expanded( // Wrap buttons with Flexible for adaptive sizing
                    child: OutlinedButton(
                      onPressed: verify,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified),
                            SizedBox(width: 4.0), // Add a small space between icon and text
                            Text('Verify Payment'),
                          ],
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
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



// import 'package:chapa_unofficial/chapa_unofficial.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class chapaPayment extends StatefulWidget {
//   const chapaPayment({super.key, required this.title});
//   static const String idScreen = "chapa";
//   final String title;
//
//   @override
//   State<chapaPayment> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<chapaPayment> {
//   // final int _counter = 0;
//
//   Future<void> verify() async {
//     Map<String, dynamic> verificationResult =
//     await Chapa.getInstance.verifyPayment(
//       txRef: TxRefRandomGenerator.gettxRef,
//     );
//     if (kDebugMode) {
//       print(verificationResult);
//     }
//   }
//
//   Future<void> pay() async {
//     try {
//       // Generate a random transaction reference with a custom prefix
//       String txRef = TxRefRandomGenerator.generate(prefix: 'linat');
//
//       // Access the generated transaction reference
//       String storedTxRef = TxRefRandomGenerator.gettxRef;
//
//       // Print the generated transaction reference and the stored transaction reference
//       if (kDebugMode) {
//         print('Generated TxRef: $txRef');
//         print('Stored TxRef: $storedTxRef');
//       }
//       await Chapa.getInstance.startPayment(
//         context: context,
//         onInAppPaymentSuccess: (successMsg) {
//           // Handle success events
//         },
//         onInAppPaymentError: (errorMsg) {
//           // Handle error
//         },
//         amount: '1000',
//         currency: 'ETB',
//         txRef: storedTxRef,
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(" payment"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'pay to linat416',
//             ),
//             TextButton(
//                 onPressed: () async {
//                   await pay();
//                 },
//                 child: const Text("Pay")),
//             TextButton(
//                 onPressed: () async {
//                   await verify();
//                 },
//                 child: const Text("Verify")),
//           ],
//         ),
//       ),
//     );
//   }
// }