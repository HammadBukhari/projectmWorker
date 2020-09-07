import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:projectmworker/model/app_messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  AppMessenger messenger;
  Future<bool> get isUserLoggedIn async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('loginStat') ?? false;
    if (status == true) {
      messenger =
          await getMessengerFromEmail(prefs.getString("messengerId") ?? "");
      if (messenger == null) return false;
      // update token
      final token = await _firebaseMessaging.getToken();
      await uploadTokenToMessengerDoc(messenger.uid, token);
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

    // upload token
    final token = await _firebaseMessaging.getToken();
    uploadTokenToMessengerDoc(messenger.uid, token);

    // register to messenger topic
    _firebaseMessaging.subscribeToTopic("messenger");

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

  Future<void> uploadTokenToMessengerDoc(
      String messengerEmail, String token) async {
    await _firebaseMessaging.subscribeToTopic("messenger");
    await FirebaseFirestore.instance
        .collection("messenger")
        .doc(messengerEmail)
        .update({"token": token});
  }
}
