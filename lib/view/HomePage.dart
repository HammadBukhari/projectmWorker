import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppPushNotification.dart';
import 'OrderScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Scaffold(
      body: Center(
        child: Container(
          child: Text(
            "Hello Waqar",
          ),
        ),
      ),
    );
  }
}
