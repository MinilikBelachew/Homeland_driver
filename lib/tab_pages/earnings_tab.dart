import 'package:driver/data_handler/app_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver/data_handler/app_data.dart';

class EarningTabPage extends StatelessWidget {
  const EarningTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Container(
          color: Colors.black38,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text("Total Earning", style: TextStyle(color: Colors.white),),
                Text("\$${Provider
                    .of<AppData>(context, listen: false)
                    .earnings}", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        ),
        ElevatedButton(onPressed: ()
            {
              
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30,vertical: 18),
              child: Row(
                children: [
                  Image.asset("images/car_ios.png",width: 70,),
                  SizedBox(width: 16,),
                  Text("Total Journey",style: TextStyle(fontSize: 16),),
                  Expanded(child: Container(child: Text("7",textAlign: TextAlign.end,style: TextStyle(fontSize: 18),),))
                ],
              ),
            ))
        
        
      ],
    );
  }
}
