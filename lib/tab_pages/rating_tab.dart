import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../config_maps.dart';

class RatingTabPage extends StatefulWidget {
  const RatingTabPage({super.key});

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22,
              ),
              Text("Yours Rating",style: TextStyle(fontSize: 20,fontFamily: "Brand-Bold",color: Colors.blue),),
              SizedBox(
                height: 22,
              ),
              Divider(height: 2,thickness: 2,),
              SizedBox(
                height: 16,
              ),


              SmoothStarRating(
                rating: startCounter,
                color: Colors.green,
                allowHalfRating: true,
                starCount: 5,
                size: 45,


                         ),


              SizedBox(
                height: 16,
              ),

              Text(title,style: TextStyle(fontSize: 55,fontFamily: "Signatra",color: Colors.green),),

              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );

  }
}
