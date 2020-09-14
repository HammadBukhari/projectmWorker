import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/route_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:background_location/background_location.dart';
import 'package:uuid/uuid.dart';

import '../HomePage.dart';
import '../OngoingOrderScreen.dart';

enum OrderAcceptanceStatus {
  success,
  unknownError,
  noInternet,
  alreadyAccepted,
  locationProblem,
}

class OrderProvider {
  final firestore = FirebaseFirestore.instance;
  ValueNotifier<Order> currentOrder = ValueNotifier(null);
  final loginProvider = GetIt.I<LoginProvider>();
  StreamSubscription<Position> positionStream;

  OrderProvider() {
    // add a listener for current order
    currentOrder.addListener(() {
      final order = currentOrder.value;
      if (order == null) return;
      BackgroundLocation.getLocationUpdates((location) {
        order.messengerLat = location.latitude;
        order.messengerLng = location.longitude;
        print("${location.latitude},${location.longitude}");

        firestore.collection("order").doc(order.orderId).update(order.toMap());
      });
    });
    // check for ongoing order
    checkForOngoingOrder();
  }

  Future<Order> getOrderUsingOrderId(String orderId) async {
    final orderDoc = await firestore.collection("order").doc(orderId).get();
    if (!orderDoc.exists) {
      return null;
    }
    return Order.fromMap(orderDoc.data());
  }

  Future<void> checkForOngoingOrder() async {
    //check ongoing orders
    final ongoingOrders = await firestore
        .collection("order")
        .where("messengerId", isEqualTo: loginProvider.messenger.uid)
        .where("isCatered", isEqualTo: false)
        .get();
    if (ongoingOrders.docs.isNotEmpty) {
      final ongoing = ongoingOrders.docs[0];
      currentOrder.value = Order.fromMap(ongoing.data());
      currentOrder.notifyListeners();
      Get.to(OngoingOrderScreen(order: currentOrder.value));
    }
  }

  Future<void> cancelCurrentOrder() async {
    Get.defaultDialog(
      title: "Loading",
      content: CircularProgressIndicator(),
    );
    final order = currentOrder.value;
    if (order != null) {
      currentOrder.value = null;
      currentOrder.notifyListeners();
      order.status = OrderStatus.orderCancelled;
      order.isCatered = true;
      await firestore
          .collection("order")
          .doc(order.orderId)
          .update(order.toMap());
      Get.offAll(HomePage());
      Get.defaultDialog(
        title: "Order Cancelled",
        content: Icon(
          Icons.cancel,
          size: 48,
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> completeCurrentOrder() async {
    Get.defaultDialog(
      title: "Loading",
      content: CircularProgressIndicator(),
    );
    final order = currentOrder.value;
    if (order != null) {
      currentOrder.value = null;
      currentOrder.notifyListeners();

      order.status = OrderStatus.orderCompleted;
      order.isCatered = true;
      await firestore
          .collection("order")
          .doc(order.orderId)
          .update(order.toMap());
      Get.offAll(HomePage());
      Get.defaultDialog(
        title: "Order Completed",
        content: Icon(
          Icons.check,
          size: 48,
        ),
      );
      return true;
    }
    return false;
  }

  Future<OrderAcceptanceStatus> acceptOrder(String orderId) async {
    try {
      Get.defaultDialog(
        title: "Loading",
        content: CircularProgressIndicator(),
      );
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final PermissionStatus status =
          await BackgroundLocation.checkPermissions();
      if (status != PermissionStatus.granted) {
        return OrderAcceptanceStatus.locationProblem;
      }

      if (position == null) return OrderAcceptanceStatus.locationProblem;
      BackgroundLocation.startLocationService();

      return FirebaseFirestore.instance
          .runTransaction<OrderAcceptanceStatus>((t) async {
        final orderDoc =
            await t.get(firestore.collection("order").doc(orderId));
        final order = Order.fromMap(orderDoc.data());
        if (order.status != OrderStatus.findingMessenger) {
          return OrderAcceptanceStatus.alreadyAccepted;
        }
        order.messengerId = loginProvider.messenger.uid;
        order.status = OrderStatus.messengerOnWay;
        order.messengerLat = position.latitude;
        order.messengerLng = position.longitude;
        final messageDocId = Uuid().v1();
        order.messageDocId = messageDocId;
        t.update(orderDoc.reference, order.toMap());
        t.set(firestore.collection("message").doc(messageDocId),
            {"orderId": order.orderId});
        currentOrder.value = order;
        currentOrder.notifyListeners();
        return OrderAcceptanceStatus.success;
      });
    } catch (e) {
      return OrderAcceptanceStatus.unknownError;
    }
  }
}
