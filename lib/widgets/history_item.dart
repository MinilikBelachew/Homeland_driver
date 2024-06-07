import 'package:driver/assistant/assistant_methods.dart';
import 'package:driver/models/history.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final History history;
  HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust margins for spacing
      child: Column(
        children: [
          _buildHistoryTile(context, history), // Separate function for each history item
          const SizedBox(height: 10.0), // Spacing between history items
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, History history) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        color: Colors.white.withOpacity(0.15), // Subtle background color
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined, // Modern icon for pickup
                  color: Theme.of(context).primaryColor,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    history.pickUp!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500, // Semi-bold for emphasis
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                Text(
                  '\E\T\B${history.fares}', // Use appropriate currency symbol
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor, // Use theme color for important info
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0), // Spacing between pickup and dropoff
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    history.dropOff!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0), // Spacing before date
            Text(
              AssistantMethods.formatTripDate(history.createdAt!),
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600], // Lighter gray for less prominence
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
// import 'package:driver/models/history.dart';
//
// class HistoryItem extends StatelessWidget {
//   //const HistoryItem({super.key});
//   final History history;
//   HistoryItem({required this.history});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           child: Row(
//             children: [
//               Image.asset('images/pickicon.png',height: 16,width: 16,),
//               SizedBox(width: 18,),
//               Expanded(child: Container(child: Text(history.pickUp!,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: Colors.red),),)),
//               SizedBox(width: 5,),
//               Text('\E\T\B${history.fares}',style: TextStyle(fontFamily: "Brand-Bold",fontSize: 16,color: Colors.black),)
//
//             ],
//           ),
//
//
//         ),
//         SizedBox(height: 8,),
//         Row(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Image.asset("images/desticon.png",height: 16,width: 16,),
//
//             SizedBox(width: 18,),
//             Text(history.dropOff!,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18),)
//           ],
//         ),
//
//         SizedBox(height: 15,),
//         Text(AssistantMethods.formatTripDate(history.createdAt!),style: TextStyle(color: Colors.grey),)
//
//
//       ],
//     ),
//     );
//   }
// }
