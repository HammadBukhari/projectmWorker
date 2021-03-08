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
  Position currentPosition;
  VoidCallback variableForListener;
  StreamSubscription<DocumentSnapshot> orderStream;
  Function(DocumentSnapshot) orderListenerFun;

  final firestore = FirebaseFirestore.instance;
  ValueNotifier<Order> currentOrder = ValueNotifier(null);
  final loginProvider = GetIt.I<LoginProvider>();
  //StreamSubscription<Position> positionStream;
  //StreamSubscription<DocumentSnapshot> orderListener = null;

  OrderProvider() {
    // add a listener for current order
    orderListenerFun = (element) {
      if (element.exists) {
        currentOrder.value = Order.fromMap(element.data());
        currentOrder.notifyListeners();
      }
    };
    variableForListener = () {
      print("listener called");
      final order = currentOrder.value;
      if (order == null) return;

      // update location of order
      if (currentPosition != null) {
        if (currentPosition.latitude != order.messengerLat ||
            currentPosition.longitude != order.messengerLng) {
          print("${currentPosition.latitude},${currentPosition.longitude}");

          firestore.collection("order").doc(order.orderId).update({
            "messengerLat": currentPosition.latitude,
            "messengerLng": currentPosition.longitude,
          });
        }
      }

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
            "orderStatus": OrderStatus.waitingForScheduleArrival.index,
            "isCatered": true
          }).then((value) {
            //orderListener.cancel();
            // currentOrder.removeListener();
            currentOrder.value = null;
            if (orderStream != null) orderStream.cancel();
            currentOrder.notifyListeners();
            print("-------------- Payment Sheduled!!!");
            Get.to(OrderHistoryPage());
            BackgroundLocation.stopLocationService();
          });
        }
      }

      BackgroundLocation.getLocationUpdates((location) {
        currentPosition = Position(
            latitude: location.latitude, longitude: location.longitude);
        currentOrder.notifyListeners();
      });
    };

    // FirebaseFirestore.instance.collection("order").where("messengerId" , isEqualTo: )

    currentOrder.addListener(variableForListener);
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
      await startOrderListener();

      // firestore
      //     .collection("order")
      //     .doc(currentOrder.value.orderId)
      //     .snapshots()
      //     .forEach((element) {
      //   if (element.exists) {
      //     currentOrder.value = Order.fromMap(element.data());
      //     currentOrder.notifyListeners();
      //   }
      // });
      Get.to(OngoingOrderScreen(order: currentOrder.value));
    }
  }

  startOrderListener() async {
    if (orderStream != null) {
      await orderStream.cancel();
    }
    if (currentOrder.value != null)
      orderStream = FirebaseFirestore.instance
          .collection("order")
          .doc(currentOrder.value.orderId)
          .snapshots()
          .listen(orderListenerFun);
  }

  Future<void> cancelCurrentOrder() async {
    Get.defaultDialog(
      title: "Loading",
      content: CircularProgressIndicator(),
    );
    final order = currentOrder.value;
    if (order != null) {
      currentOrder.value = null;
      await orderStream.cancel();
      currentOrder.notifyListeners();
      // currentOrder.removeListener(variableForListener);
      // currentOrder.notifyListeners();

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
      await orderStream.cancel();
      currentOrder.notifyListeners();
      // currentOrder.removeListener(variableForListener);

      print("Order Complete -------");
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

  Future<Position> enablePosition() async {
    try {
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final PermissionStatus status =
          await BackgroundLocation.checkPermissions();
      if (status != PermissionStatus.granted) {
        return null;
      }

      if (position == null) return null;
      BackgroundLocation.startLocationService();
      return position;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<OrderAcceptanceStatus> acceptOrder(String orderId) async {
    print("accept order => $orderId");
    try {
      final position = await enablePosition();
      if (position == null) {
        return OrderAcceptanceStatus.locationProblem;
      }

      if (currentOrder.value != null) {
        print("Order is not NULLLLL -- ");
        return OrderAcceptanceStatus.unknownError;
      }

      final result = await firestore
          .runTransaction<Tuple2<OrderAcceptanceStatus, Order>>((t) async {
        final orderDoc =
            await t.get(firestore.collection("order").doc(orderId));
        final order = Order.fromMap(orderDoc.data());
        if (order.status != OrderStatus.findingMessenger) {
          return Tuple2<OrderAcceptanceStatus, Order>(
              OrderAcceptanceStatus.alreadyAccepted, null);
        }
        print("Status is Finding Messenger -------- ");
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
        print("Transection Success -------- ");
        currentOrder.value = result.item2;
        currentOrder.notifyListeners();
        await startOrderListener();
        // firestore
        //     .collection("order")
        //     .doc(currentOrder.value.orderId)
        //     .snapshots()
        //     .forEach((element) {
        //   if (element.exists) {
        //     currentOrder.value = Order.fromMap(element.data());
        //     currentOrder.notifyListeners();
        //   }
        // });

      }
      return result.item1;
    } catch (e) {
      print("Exception Caught -------- ");
      return OrderAcceptanceStatus.unknownError;
    }
  }

  Future<bool> acceptOrderOnSceduleArrival(String orderId) async {
    try {
      final position = await enablePosition();
      if (position == null) {
        return false;
      }

      if (currentOrder.value != null) {
        return false;
      }

      await FirebaseFirestore.instance
          .collection("order")
          .doc(orderId)
          .update({"orderStatus": OrderStatus.messengerOnWay.index});
      final order = Order.fromMap((await FirebaseFirestore.instance
              .collection("order")
              .doc(orderId)
              .get())
          .data());
      currentOrder.value = order;
      currentOrder.notifyListeners();
      await startOrderListener();
      // firestore.collection("order").doc(orderId).snapshots().forEach((element) {
      //   if (element.exists) {
      //     currentOrder.value = Order.fromMap(element.data());
      //     currentOrder.notifyListeners();
      //   }
      // });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
