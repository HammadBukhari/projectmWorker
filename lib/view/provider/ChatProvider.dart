import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectmworker/model/chat.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

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

  Future<void> sendMessage(String messageDocId, String message,
      MessageType type, PaymentStatus paymentStatus) {
    try {
      return firestore.runTransaction((t) async {
        final chatDocRef = firestore.collection("message").doc(messageDocId);
        final chatDoc = await t.get(chatDocRef);
        final chat = Chat.fromMap(chatDoc.data());
        if (chat.messages == null) {
          chat.messages = [];
        }
        chat.messages.add(Message(
          message: message,
          sender: ChatRole.messenger,
          type: type,
          paymentStatus: paymentStatus,
          sendingTime: DateTime.now().millisecondsSinceEpoch,
        ));
        t.update(chatDocRef, chat.toMap());
      });
    } catch (e) {
      print(e);
      return null;
    }
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
