import 'package:driver/assistant/assistant_methods.dart';
import 'package:flutter/material.dart';

import '../tab_pages/earnings_tab.dart';


class CollectBirrDialog extends StatelessWidget {
  final String paymentMethod;
  final int fareAmount;

  CollectBirrDialog({required this.fareAmount, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16.0), // Adjust margin for spacing
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0), // Rounded corners for a modern look
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20.0), // Spacing before content
            Text(
              paymentMethod.toUpperCase(), // All caps for emphasis
              style: const TextStyle(
                fontSize: 18.0, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Bold for prominence
              ),
            ),
            const SizedBox(height: 20.0), // Spacing before fare amount
            Text(
              '\E\T\B$fareAmount',
              style: const TextStyle(
                fontSize: 55.0, // Large font for fare amount
                fontFamily: "Brand-Bold", // Maintain existing font
              ),
            ),
            const SizedBox(height: 20.0), // Spacing after fare amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "This is the total amount to be collected from the rider.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0, // Adjust font size for text
                ),
              ),
            ),
            const SizedBox(height: 30.0), // Spacing before button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                // Close previous screen (optional)
                  AssistantMethods.enableLiveLocationUpdate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Use theme color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners for button
                  ),
                  minimumSize: const Size.fromHeight(50.0), // Set button height
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect Cash",
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for better contrast
                      ),
                    ),
                    const Icon(
                      Icons.attach_money,
                      color: Colors.white, // White icon for better contrast
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
























// import 'package:driver/assistant/assistant_methods.dart';














// import 'package:flutter/material.dart';
//
// class CollectBirrDialog extends StatelessWidget {
//   final String paymentMethod;
//   final int fareAmount;
//
//   CollectBirrDialog({required this.fareAmount, required this.paymentMethod});
//
// // CollectBirrDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       backgroundColor: Colors.transparent,
//       child: Container(
//         margin: EdgeInsets.all(5),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 22,
//             ),
//             Text("Cash Payment"),
//             SizedBox(
//               height: 22,
//             ),
//             Divider(),
//             SizedBox(
//               height: 16,
//             ),
//             Text(
//               "\E\T\B$fareAmount",
//               style: TextStyle(fontSize: 55, fontFamily: "Brand-Bold"),
//             ),
//             SizedBox(
//               height: 16,
//             ),
//             SizedBox(
//               height: 16,
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 "This Is total Amount,it has been to the rider",
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: ElevatedButton(
//                 onPressed: () async {
//
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                   AssistantMethods.enableLiveLocationUpdate();
//
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.all(17),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Collect Cash",
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                       Icon(
//                         Icons.attach_money,
//                         color: Colors.blue,
//                         size: 26,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
