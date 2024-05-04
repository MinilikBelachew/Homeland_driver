import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver/assistant/request_assistant.dart';
import 'package:driver/config_maps.dart';
import 'package:driver/data_handler/app_data.dart';
import 'package:driver/models/address.dart';
import 'package:driver/widgets/progess_dialog.dart';

import '../models/prediction_places.dart';

class PredicationTile extends StatelessWidget {
  PredicationTile({Key? key, required this.placePredication}) : super(key: key);

  final PlacePredication placePredication;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceAddressDetails(placePredication.place_id!, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10,
            ),
            Row(
              children: [

                Icon(Icons.location_on,color: Colors.black,),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                    child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placePredication.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16,color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      placePredication.secondery_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Setting Dropoff, Please wait"),
    );

    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);

    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

     // Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);
      print("Address Name: ${address.placeName}");

      Navigator.pop(context, "obtainDirection");
    }
  }

  // void getPlaceAddressDtails(String placeId, context) async {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) =>
  //           ProgressDialog(message: "Setting Dropoff,Please wait"));
  //   String placeDetailsUrl =
  //       "https://maps.googleapis.com/maps/api/place/details/json &place_id=$placeId &key=$mapkey";
  //
  //   var res = await RequestAssistant.getRequest(placeDetailsUrl);
  //   Navigator.pop(context);
  //
  //   if (res == "failed") {
  //     return;
  //   }
  //   if (res["status"] == "OK") {
  //     Address address = Address();
  //     address.placeName = res["result"]["name"];
  //     address.placeId = placeId;
  //     address.latitude = res["result"]["geometry"]["location"]["lat"];
  //     address.longitude = res["result"]["geometry"]["location"]["lng"];
  //
  //
  //     Provider.of<AppData>(context,listen: false).updateDropOffLocationAddress(address);
  //     print("gfaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaajh");
  //     print(address.placeName);
  //
  //     Navigator.pop(context,"obtainDirection");
  //   }
  // }
}
