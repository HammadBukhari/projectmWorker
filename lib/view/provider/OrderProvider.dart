import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/route_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/model/app_user.dart';
import 'package:projectmworker/model/chat.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:background_location/background_location.dart';
import 'package:projectmworker/view/HomeHistoryScreen.dart';
import 'package:tuple/tuple.dart';
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
  StreamSubscription<DocumentSnapshot> orderListener = null;

  OrderProvider() {
    // add a listener for current order

    // FirebaseFirestore.instance.collection("order").where("messengerId" , isEqualTo: )
    currentOrder.addListener(() {
      final order = currentOrder.value;
      if (order == null) return;

      if (currentOrder.value.status == OrderStatus.paymentDone) {
        print("PAYMENT DONEEEEEE");
        if (currentOrder.value.scheduledTime == null) {
          print("MESSENGER ON THE WAYYYYYY");
          currentOrder.value.status = OrderStatus.messengerOnWay;
          FirebaseFirestore.instance
              .collection("order")
              .doc(order.orderId)
              .update({"orderStatus": OrderStatus.messengerOnWay.index}).then(
                  (value) {
            Get.to(OngoingOrderScreen(order: currentOrder.value));
            currentOrder.notifyListeners();
          });
        } else {
          currentOrder.value.status = OrderStatus.waitingForScheduleArrival;
          currentOrder.value.isCatered = true;
          FirebaseFirestore.instance
              .collection("order")
              .doc(order.orderId)
              .update({
            "orderStatus": OrderStatus.waitingForScheduleArrival.index
          }).then((value) {
            orderListener.cancel();
            currentOrder.value = null;
            Get.offAll(OrderHistoryPage());
            BackgroundLocation.stopLocationService();
          });
        }
      }

      BackgroundLocation.getLocationUpdates((location) {
        order.messengerLat = location.latitude;
        order.messengerLng = location.longitude;
        print("${location.latitude},${location.longitude}");

        firestore.collection("order").doc(order.orderId).update({
          "messengerLat": location.latitude,
          "messengerLng": location.longitude,
        });
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

      firestore
          .collection("order")
          .doc(currentOrder.value.orderId)
          .snapshots()
          .forEach((element) {
        if (element.exists) {
          currentOrder.value = Order.fromMap(element.data());
          currentOrder.notifyListeners();
        }
      });
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
      order.status = OrderStatus.orderCancelledByMessenger;
      order.isCatered = true;
      await firestore
          .collection("order")
          .doc(order.orderId)
          .update(order.toMap());
      Get.offAll(OrderHistoryPage());
      Get.defaultDialog(
        title: "Order Cancelled",
        content: Icon(
          Icons.cancel,
          size: 48,
        ),
      );
      BackgroundLocation.stopLocationService();

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
      Get.offAll(OrderHistoryPage());
      Get.defaultDialog(
        title: "Order Completed",
        content: Icon(
          Icons.check,
          size: 48,
        ),
      );
      BackgroundLocation.stopLocationService();
      return true;
    }
    return false;
  }

  Future<bool> assignedMessenger(String orderId) async {
    var docSnap =
        await FirebaseFirestore.instance.collection("order").doc(orderId).get();

    var order = Order.fromMap(docSnap.data());
    if (order.status != OrderStatus.findingMessenger) {
      return false;
    } else {
      order.status = OrderStatus.messengerAssigned;
      await FirebaseFirestore.instance
          .collection("order")
          .doc(orderId)
          .set(order.toMap())
          .timeout(Duration(seconds: 10), onTimeout: () {
        return false;
      });
    }
    listenOrder(orderId);
    return true;
  }

  void listenOrder(String orderId) {
    var col = FirebaseFirestore.instance.collection("order").doc(orderId);
    orderListener = col.snapshots().listen((event) async {
      if (event.exists) {
        currentOrder = ValueNotifier(Order.fromMap(event.data()));
        if (currentOrder.value.status == OrderStatus.paymentDone) {
          if (currentOrder.value.scheduledTime == null) {
            final status = await acceptOrder(orderId);
            if (Get.isDialogOpen) Get.back();
            if (status == OrderAcceptanceStatus.success) {
              Fluttertoast.showToast(msg: "Order accepted");
              Get.to(OngoingOrderScreen(order: currentOrder.value));
            } else if (status == OrderAcceptanceStatus.unknownError) {
              Fluttertoast.showToast(msg: "Check your internet connection");
            } else if (status == OrderAcceptanceStatus.locationProblem) {
              Fluttertoast.showToast(
                  msg:
                      "Unable to retrieve your location. Check your location settings");
            } else if (status == OrderAcceptanceStatus.alreadyAccepted) {
              Fluttertoast.showToast(
                  msg: "Order accepted by another Messenger.");
              Get.offAll(HomePage());
            }
          } else {
            currentOrder.value.status = OrderStatus.waitingForScheduleArrival;
            FirebaseFirestore.instance
                .collection("order")
                .doc(orderId)
                .set(currentOrder.value.toMap())
                .then((value) {
              orderListener.cancel();
              currentOrder.value = null;
              Get.offAll(OrderHistoryPage());
            });
          }
          // acceptOrder(orderId);
          currentOrder.notifyListeners();
        }
      }
    });
  }

  Future<OrderAcceptanceStatus> acceptOrder(String orderId) async {
    print("accept order => $orderId");
    try {
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final PermissionStatus status =
          await BackgroundLocation.checkPermissions();
      if (status != PermissionStatus.granted) {
        return OrderAcceptanceStatus.locationProblem;
      }

      if (position == null) return OrderAcceptanceStatus.locationProblem;
      BackgroundLocation.startLocationService();
      if (currentOrder.value != null) return OrderAcceptanceStatus.unknownError;

      final result = await firestore
          .runTransaction<Tuple2<OrderAcceptanceStatus, Order>>((t) async {
        final orderDoc =
            await t.get(firestore.collection("order").doc(orderId));
        final order = Order.fromMap(orderDoc.data());
        if (order.status != OrderStatus.findingMessenger) {
          return Tuple2<OrderAcceptanceStatus, Order>(
              OrderAcceptanceStatus.alreadyAccepted, null);
        }
        order.messengerId = loginProvider.messenger.uid;
        order.status = OrderStatus.messengerAssigned;
        order.messengerLat = position.latitude;
        order.messengerLng = position.longitude;
        final messageDocId = Uuid().v1();
        order.messageDocId = messageDocId;
        final userToken = AppUser.fromMap(
          (await t.get(
            firestore.collection("user").doc(order.userUid),
          ))
              .data(),
        ).token;
        final orderWithoutTokens = order.toMap();
        final orderWithTokens = orderWithoutTokens
          ..putIfAbsent(
              "messengerNotifToken", () => loginProvider.messenger.token)
          ..putIfAbsent("userNotifToken", () => userToken);
        t.set(
            firestore.collection("message").doc(messageDocId),
            Chat(
              orderId: orderId,
              messengerNotifToken: loginProvider.messenger.token,
              userNotifToken: userToken,
              messages: [],
            ).toMap());

        t.update(orderDoc.reference, orderWithTokens);

        return Tuple2<OrderAcceptanceStatus, Order>(
            OrderAcceptanceStatus.success, order);
      }, timeout: Duration(seconds: 10));
      if (result.item1 == OrderAcceptanceStatus.success) {
        currentOrder.value = result.item2;
        firestore
            .collection("order")
            .doc(currentOrder.value.orderId)
            .snapshots()
            .forEach((element) {
          if (element.exists) {
            currentOrder.value = Order.fromMap(element.data());
            currentOrder.notifyListeners();
          }
        });

        currentOrder.notifyListeners();
      }
      return result.item1;
    } catch (e) {
      return OrderAcceptanceStatus.unknownError;
    }
  }

  // Future<OrderAcceptanceStatus> acceptOrder(String orderId) async {
  //   print("accept order => $orderId");
  //   try {
  //     Position position = await getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.bestForNavigation);

  //     final PermissionStatus status =
  //         await BackgroundLocation.checkPermissions();
  //     if (status != PermissionStatus.granted) {
  //       return OrderAcceptanceStatus.locationProblem;
  //     }

  //     if (position == null) return OrderAcceptanceStatus.locationProblem;
  //     BackgroundLocation.startLocationService();
  //     if (currentOrder.value != null) return OrderAcceptanceStatus.unknownError;

  //     final result = await firestore
  //         .runTransaction<Tuple2<OrderAcceptanceStatus, Order>>((t) async {
  //       final orderDoc =
  //           await t.get(firestore.collection("order").doc(orderId));
  //       final order = Order.fromMap(orderDoc.data());
  //       if (order.status != OrderStatus.findingMessenger) {
  //         return Tuple2<OrderAcceptanceStatus, Order>(
  //             OrderAcceptanceStatus.alreadyAccepted, null);
  //       }
  //       order.messengerId = loginProvider.messenger.uid;
  //       // order.status = OrderStatus.messengerOnWay;
  //       order.messengerLat = position.latitude;
  //       order.messengerLng = position.longitude;
  //       final messageDocId = Uuid().v1();
  //       order.messageDocId = messageDocId;
  //       final userToken = AppUser.fromMap(
  //         (await t.get(
  //           firestore.collection("user").doc(order.userUid),
  //         ))
  //             .data(),
  //       ).token;
  //       final orderWithoutTokens = order.toMap();
  //       final orderWithTokens = orderWithoutTokens
  //         ..putIfAbsent(
  //             "messengerNotifToken", () => loginProvider.messenger.token)
  //         ..putIfAbsent("userNotifToken", () => userToken);
  //       t.set(
  //           firestore.collection("message").doc(messageDocId),
  //           Chat(
  //             orderId: orderId,
  //             messengerNotifToken: loginProvider.messenger.token,
  //             userNotifToken: userToken,
  //             messages: [],
  //           ).toMap());

  //       t.update(orderDoc.reference, orderWithTokens);

  //       return Tuple2<OrderAcceptanceStatus, Order>(
  //           OrderAcceptanceStatus.success, order);
  //     }, timeout: Duration(seconds: 10));
  //     if (result.item1 == OrderAcceptanceStatus.success) {
  //       currentOrder.value = result.item2;
  //       currentOrder.notifyListeners();
  //     }
  //     return result.item1;
  //   } catch (e) {
  //     return OrderAcceptanceStatus.unknownError;
  //   }
  // }

}
