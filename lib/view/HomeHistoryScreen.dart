import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:projectmworker/model/app_messenger.dart';
import 'package:projectmworker/model/order.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:projectmworker/shared/color.dart';

class ProjectsExpansionTile extends StatelessWidget {
  ProjectsExpansionTile(
      {this.projectKey,
      this.name,
      this.firestore,
      this.order,
      this.sourceLocationName,
      this.destLocationName,
      this.status,
      this.instruction,
      this.fare});

  final String sourceLocationName;
  final String destLocationName;
  final OrderStatus status;
  final String instruction;
  final String fare;

  final Order order;
  final String projectKey;
  final String name;
  final FirebaseFirestore firestore;
  final provider = GetIt.I<LoginProvider>();
  Color statusButtonColor = AppColor.buttonColor;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Opacity(
                child: Text(
                    DateFormat.yMMMMd('en_US').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                order.creationTime)) +
                        " | " +
                        DateFormat.jm().format(
                            DateTime.fromMillisecondsSinceEpoch(order
                                .creationTime)) /*"July 1, 2020 | 4:20 PM"*/,
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                opacity: 0.8,
              ),
              Expanded(
                child: SizedBox(),
              ),
              Opacity(
                child: Text("$fare AED | Credit Card",
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                opacity: 0.8,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Opacity(
                child: Text(
                  "Order No. ${order.userOrderNo}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                opacity: 0.5,
              ),
              Expanded(
                child: SizedBox(),
              ),
              ButtonTheme(
                height: 30,
                minWidth: 100,
                child: RaisedButton(
                  child: Text(
                    (() {
                      if (status == OrderStatus.findingMessenger) {
                        statusButtonColor = Colors.red;
                        return "Pending";
                      } else if (status == OrderStatus.messengerOnWay) {
                        statusButtonColor = AppColor.buttonColor;
                        return "On the Way";
                      } else if (status == OrderStatus.findingMessengerFailed) {
                        statusButtonColor = Colors.red;
                        return "Failed";
                      } else if (status == OrderStatus.orderCancelled) {
                        statusButtonColor = Colors.red;
                        return "Cancelled";
                      } else if (status == OrderStatus.orderCompleted) {
                        statusButtonColor = AppColor.primaryColor;
                        return "Completed";
                      }
                    }()),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12),
                  ),
                  onPressed: () {},
                  color: statusButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              )
            ],
          ),
          Divider()
        ],
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x45CCCCCC),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
                bottomRight: const Radius.circular(10.0),
                bottomLeft: const Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(
                            Icons.shopping_cart,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Pickup Location:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primaryColor),
                                ),
                                alignment: Alignment.topLeft,
                              ),
                              Container(
                                child: Text(
                                  sourceLocationName,
                                  style:
                                      TextStyle(color: AppColor.primaryColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                alignment: Alignment.topLeft,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(
                            Icons.location_on,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Dropoff Location:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primaryColor),
                                ),
                                alignment: Alignment.topLeft,
                              ),
                              Container(
                                child: Text(
                                  destLocationName,
                                  style:
                                      TextStyle(color: AppColor.primaryColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                alignment: Alignment.topLeft,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Opacity(
                    child: Text(
                      "Instructions:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    opacity: 0.8,
                  ),
                  alignment: Alignment.topLeft,
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    child: Text(instruction,
                        style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Opacity(
                    child: Text(
                      "Messenger:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    opacity: 0.8,
                  ),
                  alignment: Alignment.topLeft,
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('messenger')
                          .doc(order.messengerId)
                          .get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final messengerDoc = snapshot.data.data();
                          if (messengerDoc != null) {
                            var messengerName =
                                AppMessenger.fromMap(messengerDoc).name;
                            return Text(messengerName,
                                style: TextStyle(color: Colors.black));
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    )),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: AppColor.primaryColor,
                    ),
                    Icon(
                      Icons.star,
                      color: AppColor.primaryColor,
                    ),
                    Icon(
                      Icons.star,
                      color: AppColor.primaryColor,
                    ),
                    Icon(
                      Icons.star,
                      color: AppColor.primaryColor,
                    ),
                    Icon(
                      Icons.star_border,
                      color: AppColor.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Opacity(
                    child: Text(
                      "Comments to the driver:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    opacity: 0.8,
                  ),
                  alignment: Alignment.topLeft,
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                        "Very attentive and patient! Keep up the good work.",
                        style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ExpansionTileList extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final FirebaseFirestore firestore;

  ExpansionTileList({this.documents, this.firestore});

  List<Widget> _getChildren() {
    List<Widget> children = [];
    documents.forEach((doc) {
      var order = Order.fromMap(doc.data());
      children.add(
        ProjectsExpansionTile(
          order: order,
          sourceLocationName: order.sourceLocationName,
          destLocationName: order.destLocationName,
          status: order.status,
          fare: order.fare.toString(),
          instruction: order.instruction,
          name: doc.data()['orderId'],
          projectKey: doc.id,
          firestore: firestore,
        ),
      );
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getChildren(),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
//  Function changeRoute;
//  OrderHistoryPage(this.changeRoute);
  static const String routeName = '/OrderHistory';
  @override
  State<StatefulWidget> createState() {
    return OrderHistoryState();
  }
}

class OrderHistoryState extends State<OrderHistoryPage> {
  final provider = GetIt.I<LoginProvider>();

  Route _createRoute(Widget w) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) => w,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  List<Order> orders;

  @override
  void initState() {
    super.initState();
    // orders = List();
    // FirebaseFirestore.instance
    //     .collection("order")
    //     .get()
    //     .then((querySnapshot) {
    //   querySnapshot.docs.forEach((result) {
    //     orders.add(Order.fromMap(result.data()));
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Color(0xFF854dff),
        title: Text(
          'Messengers',
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.card_giftcard),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order')
            .where("messengerId", isEqualTo: provider.messenger.uid)
            .orderBy("creationTime", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //final int projectsCount = snapshot.data.documents.length;
          List<DocumentSnapshot> documents = snapshot.data.docs;
          return documents.length != 0
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
                      child: Container(
                        child: Text(
                          "Order History",
                          style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.bold,
                              color: AppColor.buttonColor,
                              fontFamily: "Open Sans"),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    ),
                    Expanded(
                      child: ExpansionTileList(
                        firestore: FirebaseFirestore.instance,
                        documents: documents,
                      ),
                    )
                  ],
                )
              : Opacity(
                  opacity: 0.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage(
                              "assets/images/order_history_icon.png"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "No Order Yet",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
//      drawer: appDrawer(context,"OrderHistoryPage",this.widget.changeRoute),
    );
  }
}
