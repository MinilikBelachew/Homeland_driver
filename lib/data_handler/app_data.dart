import 'package:flutter/cupertino.dart';
import 'package:driver/models/address.dart';

class AppData extends ChangeNotifier {






String earnings="0";
void updateEarnings(String updateEarnings)
{
  earnings=updateEarnings;
  notifyListeners();
}





}