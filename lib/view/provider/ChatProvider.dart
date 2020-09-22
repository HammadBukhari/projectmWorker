import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectmworker/model/chat.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


class ChatProvider {
  final firestore = FirebaseFirestore.instance;

  Future<String> getUserName(String userId) async {
    final messengerDoc = await firestore.collection("user").doc(userId).get();
    if (!messengerDoc.exists) {
      return null;
    }
    return messengerDoc.data()['name'];
  }

  Stream<Chat> getMessageStream(String messageDocId) => firestore
      .collection("message")
      .doc(messageDocId)
      .snapshots()
      .map((event) => Chat.fromMap(event.data()));
   Future<void> sendMessageNotification(
    String messageDocId,
    String title,
    String body,
  ) async {
    final chatDoc =
        await firestore.collection("message").doc(messageDocId).get();
    final chat = Chat.fromMap(chatDoc.data());

    // final order = GetIt.I<OrderProvider>().currentOrder.value;
    // if (order == null) return;

    const serverToken =
        "AAAAflSdga0:APA91bGsDji3ZNhOJv_vXh3GpTbMyf6OEF4oeCjsFPngsIZiU_cnfSgC1IZr9xnb6vKcApG_SP97m75qg64zkIzQK72S0rSYI7mJV0itgmwXGgeLjxQZohmSeBZleYwAsE0eMT5B1QIV";
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'notification_order_id': chat.orderId,
          },
          'to': chat.userNotifToken,
        },
      ),
    );
  }

  Future<void> sendMessage(String messageDocId, String message,
      MessageType type, PaymentStatus paymentStatus) {
    final messageMap = Message(
      message: message,
      sender: ChatRole.messenger,
      type: type,
      paymentStatus: paymentStatus,
      sendingTime: DateTime.now().millisecondsSinceEpoch,
    ).toMap();
    firestore.collection("message").doc(messageDocId).update({
      "messages": FieldValue.arrayUnion([messageMap])
    });
    String notifMessage;
    if (type == MessageType.text)
      notifMessage = message;
    else if (type == MessageType.image)
      notifMessage = "Sent you a picture.";
    else if (type == MessageType.money) notifMessage = "Sent you a $message AED.";
    sendMessageNotification(
      messageDocId,
      "Messenger",
      notifMessage,
    );

    // try {
    //   return firestore.runTransaction((t) async {
    //     final chatDocRef = firestore.collection("message").doc(messageDocId);
    //     final chatDoc = await t.get(chatDocRef);
    //     final chat = Chat.fromMap(chatDoc.data());
    //     if (chat.messages == null) {
    //       chat.messages = [];
    //     }
    //     chat.messages.add(Message(
    //       message: message,
    //       sender: ChatRole.messenger,
    //       type: type,
    //       paymentStatus: paymentStatus,
    //       sendingTime: DateTime.now().millisecondsSinceEpoch,
    //     ));
    //     t.update(chatDocRef, chat.toMap());
    //   });
    // } catch (e) {
    //   print(e);
    //   return null;
    // }
  }

  Future<String> uploadUserImage(ui.Image toUpload) async {
    var byteData = await toUpload.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String tempFilePath = path.join(tempPath, "{Uuid().v1()}.png");
    final fileToUpload = File(tempFilePath)..writeAsBytesSync(buffer);

    final storage = FirebaseStorage.instance;
    // final StorageMetadata metaData = StorageMetadata()
    final snapshot = await storage
        .ref()
        .child("user/chat/${Uuid().v1()}.png")
        .putFile(fileToUpload)
        .onComplete;
    return await snapshot.ref.getDownloadURL();
  }

  Future<File> pickImageForRegistration() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 1500,
        maxWidth: 1500);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }
}
