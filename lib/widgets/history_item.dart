import 'package:driver/assistant/assistant_methods.dart';
import 'package:flutter/material.dart';
import 'package:driver/models/history.dart';

class HistoryItem extends StatelessWidget {
  //const HistoryItem({super.key});
  final History history;
  HistoryItem({required this.history});



  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            children: [
              Image.asset('images/pickicon.png',height: 16,width: 16,),
              SizedBox(width: 18,),
              Expanded(child: Container(child: Text(history.pickUp!,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: Colors.red),),)),
              SizedBox(width: 5,),
              Text('\E\T\B${history.fares}',style: TextStyle(fontFamily: "Brand-Bold",fontSize: 16,color: Colors.black),)

            ],
          ),


        ),
        SizedBox(height: 8,),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset("images/desticon.png",height: 16,width: 16,),

            SizedBox(width: 18,),
            Text(history.dropOff!,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18),)
          ],
        ),

        SizedBox(height: 15,),
        Text(AssistantMethods.formatTripDate(history.createdAt!),style: TextStyle(color: Colors.grey),)


      ],
    ),
    );
  }
}