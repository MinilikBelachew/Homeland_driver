import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver/notification/push_notification_service.dart';
import 'package:geolocator/geolocator.dart';
import '../data_handler/app_data.dart';
import '../tab_pages/earnings_tab.dart';
import '../tab_pages/home_tab.dart';
import '../tab_pages/profile_tab.dart';
import '../tab_pages/rating_tab.dart';
import '../tab_pages/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String idScreen = "mainscreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController? tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tabController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // Set driver offline when the app is closed
      makeDriverOffline();
    }
  }

  void makeDriverOffline() {
    final currentfirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentfirebaseUser != null) {
      Geofire.removeLocation(currentfirebaseUser.uid);
      DatabaseReference rideRequestRref = FirebaseDatabase.instance.ref().child("drivers/${currentfirebaseUser.uid}/newRide");
      rideRequestRref.onDisconnect();
      rideRequestRref.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppData languageProvider = Provider.of<AppData>(context);
    var language = languageProvider.isEnglishSelected;
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: language ? "Home" : "መነሻ ገጽ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: language ? "Earnings" : "ገቢ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: language ? "Rating" : "ደረጃ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: language ? "Account" : "መለያ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: language ? "Setting" : "ቅንብሮች",
          ),
        ],
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.tealAccent,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:driver/notification/push_notification_service.dart';
// import 'package:geolocator/geolocator.dart';
// import '../data_handler/app_data.dart';
// import '../tab_pages/earnings_tab.dart';
// import '../tab_pages/home_tab.dart';
// import '../tab_pages/profile_tab.dart';
// import '../tab_pages/rating_tab.dart';
// import '../tab_pages/setting.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);
//   static const String idScreen = "mainscreen";
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   TabController? tabController;
//   int selectedIndex = 0;
//
//   void onItemClicked(int index) {
//     setState(() {
//       selectedIndex = index;
//       tabController!.index = selectedIndex;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     PushNotificationService pushNotificationService = PushNotificationService();
//     pushNotificationService.initialize(context);
//     pushNotificationService.getToken();
//     tabController = TabController(length: 5, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     tabController!.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
//       // Set driver offline
//       makeDriverOffline();
//     }
//   }
//
//   void makeDriverOffline() {
//     final currentfirebaseUser = FirebaseAuth.instance.currentUser;
//     if (currentfirebaseUser != null) {
//       Geofire.removeLocation(currentfirebaseUser.uid);
//       DatabaseReference rideRequestRref = FirebaseDatabase.instance.ref().child("drivers/${currentfirebaseUser.uid}/newRide");
//       rideRequestRref.onDisconnect();
//       rideRequestRref.remove();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     AppData languageProvider = Provider.of<AppData>(context);
//     var language = languageProvider.isEnglishSelected;
//     return Scaffold(
//       body: TabBarView(
//         physics: NeverScrollableScrollPhysics(),
//         controller: tabController,
//         children: [
//           HomeTabPage(),
//           EarningTabPage(),
//           RatingTabPage(),
//           ProfileTabPage(),
//           SettingPage(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: language ? "Home" : "መነሻ ገጽ",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.credit_card),
//             label: language ? "Earnings" : "ገቢ",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.star),
//             label: language ? "Rating" : "ደረጃ",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: language ? "Account" : "መለያ",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: language ? "Setting" : "ቅንብሮች",
//           ),
//         ],
//         unselectedItemColor: Colors.black54,
//         backgroundColor: Colors.tealAccent,
//         selectedItemColor: Colors.black,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: TextStyle(fontSize: 12),
//         showUnselectedLabels: true,
//         currentIndex: selectedIndex,
//         onTap: onItemClicked,
//       ),
//     );
//   }
// }












// import 'package:driver/assistant/assistant_methods.dart';
//
// import 'package:driver/tab_pages/earnings_tab.dart';
// import 'package:driver/tab_pages/home_tab.dart';
// import 'package:driver/tab_pages/profile_tab.dart';
// import 'package:driver/tab_pages/rating_tab.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../data_handler/app_data.dart';
// import '../notification/push_notification_service.dart';
// import '../tab_pages/setting.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//   static const String idScreen = "mainscreen";
//
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
//   TabController? tabController;
//   int selectedIndex=0;
//   void onItemClicked(int index)
//   {setState(() {
//     selectedIndex=index;
//     tabController!.index=selectedIndex;
//   });
//
//   }
//
//
//   @override
//   void initState() {
//
//     PushNotificationService pushNotificationService = PushNotificationService();
//     pushNotificationService.initialize(context);
//     pushNotificationService.getToken();
//     // TODO: implement initState
//     super.initState();
//     tabController = TabController(length: 5, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     tabController!.dispose();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//      AppData languageProvider = Provider.of<AppData>(context);
//      var language = languageProvider.isEnglishSelected;
//     return Scaffold(
//       body: TabBarView(
//         physics: NeverScrollableScrollPhysics(),
//         controller: tabController,
//         children: [
//           HomeTabPage(),
//           EarningTabPage(),
//           RatingTabPage(),
//           ProfileTabPage(),
//           SettingPage()
//
//         ],
//
//
//       ),
//
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home),
//           label: language? "Home":"መነሻ ገጽ"
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.credit_card),
//               label: language?"Earnings":"ገቢ"
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.star),
//               label: language?"Rating":"ደረጃ"
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person),
//               label: language?"Account":"መለያ"
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.settings),
//               label:language? "Setting":"ቅንብሮች "
//           ),
//
//         ],
//
//         unselectedItemColor: Colors.black54,
//         backgroundColor: Colors.tealAccent,
//         selectedItemColor: Colors.black,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: TextStyle(fontSize: 12),
//         showUnselectedLabels: true,
//         currentIndex: selectedIndex,
//         onTap: onItemClicked,
//       ),
//     );
//   }
// }
