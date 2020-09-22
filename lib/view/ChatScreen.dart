import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:projectmworker/model/app_messenger.dart';
import 'package:projectmworker/model/chat.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/shared/color.dart';
import 'dart:ui' as ui;

import 'ImageViewerScreen.dart';
import 'authentication/crop_image_screen.dart';
import 'provider/ChatProvider.dart';
import 'provider/InternetCheckProvider.dart';

class ChatScreen extends StatefulWidget {
  final Order order;
  ChatScreen({this.order});
  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  bool isTextEmpty = true;
  ValueNotifier<bool> isBusy = ValueNotifier(false);
  final paymentTEC = TextEditingController();

  final provider = GetIt.I<ChatProvider>();
  final textEditingController = TextEditingController();
  final msgListController = ScrollController();
  bool _isScrolledForFirstTime = false;

  @override
  void initState() {
    super.initState();

    getMessenger();
    isBusy.addListener(() {
      if (isBusy.value) {
        Get.defaultDialog(
          title: "Uploading Image",
          backgroundColor: Colors.grey[100],
          content: CircularProgressIndicator(),
        );
      } else {
        Get.back();
      }
    });
    internetConnectivityChecker();
    // scrollMessageListToEnd();
    // msgListController.addListener(() {
    //   if (msgListController.hasClients && !_isScrolledForFirstTime) {
    //   }
    // });
  }

  void internetConnectivityChecker() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      GetIt.I<InternetCheckProvider>().isInternetAvailable.then((value) {
        if (!value && !Get.isSnackbarOpen) {
          Get.snackbar(
            "No Internet Connection",
            "Make sure you are connected to a stable WiFi/Mobile Data connection",
            snackPosition: SnackPosition.TOP,
          );
        }
      });
    });
  }

  String userName;

  getMessenger() async {
    // messenger = await provider.getMessengerUsingId(widget.order.messengerId);
    userName = await provider.getUserName(widget.order.userUid);
    setState(() {});
  }

  void pickImage() {
    provider.pickImageForRegistration().then((value) async {
      if (value != null) {
        final ui.Image result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropImageScreen(
                image: value,
              ),
              settings: RouteSettings(name: "CropImageScreen"),
            ));

        if (result != null) {
          String url = await provider.uploadUserImage(result);
          await provider.sendMessage(
            widget.order.messageDocId,
            url,
            MessageType.image,
            PaymentStatus.none,
          );
          scrollMessageListToEnd();
          setState(() {
            isBusy.value = false;
          });
        }
      }
    });
  }

  Widget _buildChatBubble(Message m) {
    return Align(
      alignment: m.sender == ChatRole.messenger
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      child: Builder(
        builder: (context) {
          if (m.type == MessageType.text) {
            return Bubble(
              color: m.sender == ChatRole.messenger
                  ? AppColor.primaryColor
                  : Colors.grey[50],
              nip: m.sender == ChatRole.messenger
                  ? BubbleNip.rightBottom
                  : BubbleNip.leftBottom,
              elevation: 5.toDouble(),
              margin: BubbleEdges.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    m.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: m.sender == ChatRole.messenger
                            ? Colors.white
                            : AppColor.primaryColor),
                  ),
                  Text(
                    DateFormat.jm().format(
                        DateTime.fromMillisecondsSinceEpoch(m.sendingTime)),
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: m.sender == ChatRole.messenger
                          ? Colors.white54
                          : Colors.black,
                    ),
                  )
                ],
              ),
            );
          } else if (m.type == MessageType.image) {
            return InkWell(
              onTap: () {
                Get.to(ImageViewerScreen(imageUrl: m.message));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: m.message,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) {
                    return CircularProgressIndicator(
                      value: progress.progress,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Text("Unable to load image");
                  },
                ),
              ),
            );
          } else if (m.type == MessageType.money) {
            return InkWell(
              onTap: () {
                Get.defaultDialog(
                  title: "This is a verfied Payment",
                  backgroundColor: Colors.grey[100],
                  content: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: 150,
                  color: AppColor.primaryColor,
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AutoSizeText(
                              "AED ${m.message}",
                              maxLines: 2,
                              style: TextStyle(fontSize: 35),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildChatBubbleRow(Message m) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
      child: Row(
        children: m.sender == ChatRole.messenger
            ? [
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
                Flexible(
                  flex: 6,
                  child: _buildChatBubble(m),
                ),
              ]
            : [
                Flexible(
                  flex: 6,
                  child: _buildChatBubble(m),
                ),
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
              ],
      ),
    );
  }

  Widget _buildChatBody(BuildContext context) {
    return StreamBuilder<Chat>(
      stream: provider.getMessageStream(widget.order.messageDocId),
      builder: (BuildContext context, AsyncSnapshot<Chat> snapshot) {
        if (!snapshot.hasData) return Container();
        if (snapshot.data.messages == null)
          return Center(
            child: Text(""),
          );

        final reversedMessages = snapshot.data.messages.reversed.toList();
        return ListView(
          reverse: true,
          children: reversedMessages.map((m) {
            return _buildChatBubbleRow(m);
          }).toList(),
          controller: msgListController,
        );
      },
    );
  }

  void scrollMessageListToEnd() {
    msgListController.animateTo(
      msgListController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  Widget _buildMessageComposeBar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: AppColor.primaryColor,
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: [
                        CupertinoButton(
                          onPressed: () {
                            Get.back();
                            setState(() {
                              isBusy.value = true;
                            });
                            pickImage();
                          },
                          child: Text(
                            "Image",
                            style: TextStyle(color: AppColor.primaryColor),
                          ),
                        ),
                        // CupertinoButton(
                        //   onPressed: () {
                        //     Get.back();
                        //     Get.defaultDialog(
                        //       title: 'Enter Amount',
                        //       content: TextField(
                        //         controller: paymentTEC,
                        //         keyboardType: TextInputType.numberWithOptions(
                        //           signed: false,
                        //           decimal: true,
                        //         ),
                        //       ),
                        //       actions: [
                        //         FlatButton(
                        //           onPressed: () {
                        //             Get.back();
                        //           },
                        //           child: Text(
                        //             "Cancel",
                        //           ),
                        //         ),
                        //         FlatButton(
                        //           onPressed: () async {
                        //             try {
                        //               double.parse(paymentTEC.text.trim());
                        //               // if parsable then continue, else show error

                        //               // TODO: deduct amount

                        //               await provider.sendMessage(
                        //                   widget.order.messageDocId,
                        //                   paymentTEC.text.trim(),
                        //                   MessageType.money,
                        //                   PaymentStatus.completed);
                        //               scrollMessageListToEnd();
                        //               Get.back();
                        //             } catch (e) {
                        //               Get.defaultDialog(
                        //                 title: "Invalid Amount",
                        //                 content: Text(
                        //                     "The amount you entered is invalid"),
                        //               );
                        //             }
                        //           },
                        //           child: Text("Confirm"),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        //   child: Text(
                        //     "Payment",
                        //     style: TextStyle(color: AppColor.primaryColor),
                        //   ),
                        // ),
                      ],
                      cancelButton: CupertinoButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: TextFormField(
                controller: textEditingController,
                onChanged: (s) {
                  if (s.isNotEmpty && isTextEmpty) {
                    setState(() {
                      isTextEmpty = false;
                    });
                  } else if (s.isEmpty && !isTextEmpty) {
                    setState(() {
                      isTextEmpty = true;
                    });
                  }
                },
                decoration: const InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: isTextEmpty ? Colors.grey : AppColor.primaryColor,
              ),
              onPressed: () async {
                if (!isTextEmpty) {
                  provider.sendMessage(
                    widget.order.messageDocId,
                    textEditingController.text.trim(),
                    MessageType.text,
                    PaymentStatus.none,
                  );
                  textEditingController.clear();

                  scrollMessageListToEnd();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    if (userName == null) return AppBar();

    return AppBar(
      leading: BackButton(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              "assets/logo.png",
              height: 32,
              width: 32,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: AutoSizeText(
              userName,
              overflow: TextOverflow.ellipsis,
              maxFontSize: 16,
              minFontSize: 16,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: Column(
        children: [
          Expanded(
            child: _buildChatBody(context),
          ),
          _buildMessageComposeBar(context),
        ],
      ),
    );
  }
}
