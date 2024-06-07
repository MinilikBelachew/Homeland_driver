
import 'package:driver/models/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:driver/models/address.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  String earnings = "0";
  int countJourney = 0;
  List<String>? tripHistoryKeys = [];
  List<History>? tripHistoryDataList = [];
  bool isEnglishSelected = true;
  ThemeMode _themeMode = ThemeMode.light;


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


  void toggleLanguage(bool value) {
    isEnglishSelected = value;
    notifyListeners();
  }


  ThemeMode getThemeMode() {
    return _themeMode;
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }


  // AppData languageProvider = Provider.of<AppData>(context);
  // var language = languageProvider.isEnglishSelected;




}
