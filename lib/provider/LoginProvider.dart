import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:projectmworker/model/app_messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider {
  AppMessenger messenger;
  Future<bool> get isUserLoggedIn async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('loginStat') ?? false;
    if (status == true) {
      messenger =
          await getMessengerFromEmail(prefs.getString("messengerId") ?? "");
      if (messenger == null) return false;
    }
    return status;
  }

  Future<bool> loginWithEmail(String email, String password) async {
    final userDoc = await FirebaseFirestore.instance
        .collection("messenger")
        .doc(email)
        .get();
    if (!userDoc.exists) return false;

    if (userDoc.data()['passcode'].toString() != password) return false;

    messenger = AppMessenger.fromMap(userDoc.data());
    // save user status and id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('messengerId', messenger.uid);
    prefs.setBool('loginStat', true);

    return true;
  }

  Future<AppMessenger> getMessengerFromEmail(String email) async {
    final userDoc = await FirebaseFirestore.instance
        .collection("messenger")
        .doc(email)
        .get();
    if (!userDoc.exists) return null;
    return AppMessenger.fromMap(userDoc.data());
  }
}
