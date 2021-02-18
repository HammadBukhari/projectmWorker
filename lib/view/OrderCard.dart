import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/shared/color.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key key, this.order}) : super(key: key);
  Widget _infoRow(String heading, String data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Text(
              heading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: Text(
              data,
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 50,
            color: AppColor.primaryColor,
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "Order: ${order.orderId}",
                      minFontSize: 10,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 20,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                _infoRow("Pickup", order.sourceLocationName),
                _infoRow("Destination", order.destLocationName),
                _infoRow("Estimated Time", "24 Minutes"),
                _infoRow("Instruction", order.instruction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
