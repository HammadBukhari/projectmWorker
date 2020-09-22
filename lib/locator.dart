import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/view/HomePage.dart';
import 'package:projectmworker/view/OngoingOrderScreen.dart';
import 'package:projectmworker/view/OrderScreen.dart';
import 'package:projectmworker/view/provider/ChatProvider.dart';
import 'package:projectmworker/view/provider/InternetCheckProvider.dart';

import 'model/order.dart';
import 'provider/LoginProvider.dart';
import 'view/ChatScreen.dart';
import 'view/authentication/auth_screen.dart';
import 'view/provider/OrderProvider.dart';

Future<Widget> setup() async {
  GetIt.I.registerSingleton(LoginProvider());
  GetIt.I.registerSingleton(InternetCheckProvider());

  GetIt.I.registerSingleton(ChatProvider());
  if (await GetIt.I<LoginProvider>().isUserLoggedIn) {
    GetIt.I.registerSingleton(OrderProvider());

    // // return OrderScreen("8616c10a-2885-4558-83b0-e26f862b4f2a");
    // final orderDoc = await FirebaseFirestore.instance
    //     .collection("order")
    //     .doc("3b28ef86-0fcd-4e13-84c7-9ea9e665dbda")
    //     .get();
    // return OngoingOrderScreen(
    //   order: Order.fromMap(orderDoc.data()),
    // );

    // final orderDoc = await FirebaseFirestore.instance
    //     .collection("order")
    //     .doc("022103ac-d91d-49db-a8ea-2e2bd853c2bf")
    //     .get();
    // return ChatScreen(
    //   order: Order.fromMap(orderDoc.data()),
    // );

    return FirebaseNotificationScreen();
  }

  return LoginScreen();
}
