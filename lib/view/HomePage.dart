import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:projectmworker/shared/color.dart';

import '../AppPushNotification.dart';
import 'OrderScreen.dart';

class FirebaseNotificationScreen extends StatefulWidget {
  @override
  _FirebaseNotificationScreenState createState() =>
      _FirebaseNotificationScreenState();
}

class _FirebaseNotificationScreenState
    extends State<FirebaseNotificationScreen> {
  _configFirebaseMessaging() {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        if (message["data"]["orderId"] != null) {
          Get.to(OrderScreen(message["data"]["orderId"]));
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        if (message["data"]["orderId"] != null) {
          Get.to(OrderScreen(message["data"]["orderId"]));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        if (message["data"]["orderId"] != null) {
          Get.to(OrderScreen(message["data"]["orderId"]));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _configFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loginProvider = GetIt.I<LoginProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            // end: Alignment.bottomCenter,
            colors: [
              AppColor.primaryColor,
              AppColor.buttonColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Hello ${loginProvider.messenger.uid}",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Waiting for new orders.\nYou will receive a notification for order. ",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
