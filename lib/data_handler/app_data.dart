
import 'package:driver/models/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:driver/models/address.dart';

class AppData extends ChangeNotifier {
  String earnings = "0";
  int countJourney = 0;
  List<String>? tripHistoryKeys = [];
  List<History>? tripHistoryDataList = [];


  void updateEarnings(String updateEarnings) {
    earnings = updateEarnings;
    notifyListeners();
  }


  void updateTripCounter(int journyCounter) {
    countJourney=journyCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String>  newKeys)
  {
    tripHistoryKeys=newKeys;
    notifyListeners();
  }


  void updateHistoryData(History eachHistory)
  {
    tripHistoryDataList!.add(eachHistory);

    notifyListeners();
  }

}
