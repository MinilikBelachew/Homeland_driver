import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart' as audio_player_notification;
import 'package:driver/models/drivers.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/all_user.dart';
import 'package:geolocator/geolocator.dart';
String mapkey="";

User? firebaseUser;
Users? userCurrentInf;
User? currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription;
StreamSubscription<Position>? rideStreamSubscription;

final assetsAudioPlayer=audio_player_notification.AssetsAudioPlayer();
late Position currentPosition;
Drivers? driversInformation;
