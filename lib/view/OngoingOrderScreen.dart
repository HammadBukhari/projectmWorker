import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/shared/color.dart';
import 'package:projectmworker/view/OrderCard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/route_manager.dart';

import 'ChatScreen.dart';
import 'provider/OrderProvider.dart';

class OngoingOrderScreen extends StatelessWidget {
  final Order order;
  final provider = GetIt.I<OrderProvider>();

  OngoingOrderScreen({Key key, this.order}) : super(key: key);

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          toolbarHeight: 70,
          backgroundColor: Color(0xFF854dff),
          title: Text(
            'Ongoing Order',
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OrderCard(order: order),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  elevation: 10,
                  child: Text(
                    "Open Google Map Navigation",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  onPressed: () async {
                    String origin = "${order.sourceLat},${order.sourceLng}";
                    String destination = "${order.destLat},${order.destlng}";
                    String url =
                        "https://www.google.com/maps/dir/?api=1&origin=" +
                            origin +
                            "&destination=" +
                            destination +
                            "&travelmode=driving&dir_action=navigate";

                    // const url =
                    //     'https://www.google.com/maps/dir/?api=1&origin=43.7967876,-79.5331616&destination=43.5184049,-79.8473993&waypoints=43.1941283,-79.59179|43.7991083,-79.5339667|43.8387033,-79.3453417|43.836424,-79.3024487&travelmode=driving&dir_action=navigate';
                    _launchURL(url);
                  },
                  color: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  elevation: 10,
                  child: Text(
                    "Open Chat",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Get.to(ChatScreen(
                      order: order,
                    ));
                  },
                  color: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 48, bottom: 8.0),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  elevation: 10,
                  child: Text(
                    "Cancel Order",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                        fontSize: 18),
                  ),
                  onPressed: () async {
                    Get.defaultDialog(
                      title: "Cancel the Order?",
                      content: Container(),
                      actions: [
                        FlatButton(
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.green),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            provider.cancelCurrentOrder();
                          },
                        ),
                      ],
                    );
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 48, bottom: 8.0),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  elevation: 10,
                  child: Text(
                    "Complete Order",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                        fontSize: 18),
                  ),
                  onPressed: () async {
                    Get.defaultDialog(
                      title: "Finish the Order?",
                      content: Container(),
                      actions: [
                        FlatButton(
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.green),
                          ),
                          onPressed: () {
                            provider.completeCurrentOrder();
                          },
                        ),
                      ],
                    );
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
