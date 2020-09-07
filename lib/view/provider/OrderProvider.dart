import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/provider/LoginProvider.dart';

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
    currentOrder.addListener(() {
      final order = currentOrder.value;
      if (order == null) return;
      if (positionStream == null) {
        positionStream = getPositionStream(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeInterval: 5000,
        ).listen((Position position) {
          order.messengerLat = position.latitude;
          order.messengerLng = position.longitude;
          firestore
              .collection("order")
              .doc(order.orderId)
              .update(order.toMap());
        });
      }
    });
  }

  Future<OrderAcceptanceStatus> acceptOrder(String orderId) async {
    try {
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      if (position == null) return OrderAcceptanceStatus.locationProblem;

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
        t.update(orderDoc.reference, order.toMap());
        currentOrder.value = order;
        currentOrder.notifyListeners();
        return OrderAcceptanceStatus.success;
      });
    } catch (e) {
      return OrderAcceptanceStatus.unknownError;
    }
  }
}
