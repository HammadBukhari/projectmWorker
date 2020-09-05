import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:projectmworker/shared/color.dart';

import '../shared/color.dart';
import '../shared/color.dart';
import '../shared/color.dart';

//import '../HomePage.dart';

class OrderScreen extends StatefulWidget {

  OrderScreen(this.orderId);
  final String orderId;

  @override
  _OrderScreenState createState() => _OrderScreenState(orderId);
}

class _OrderScreenState extends State<OrderScreen> {

  _OrderScreenState(this.orderId);
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 15, 10),
                  child: Container(
                    child: Text(
                      "Order Request!",
                      style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: AppColor.buttonColor,
                          fontFamily: "Open Sans"),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        color: AppColor.buttonColor,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_cart,color: Colors.white,),
                              SizedBox(width: 10,),
                              Text("Order No. $orderId",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Table(
                              columnWidths: {0: FractionColumnWidth(0.4)},
                              children: [
                                TableRow(
                                  children: [
                                    Text("Pickup: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.65,
                                        child: Text("Dubai",style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.left,),
                                      ),
                                    ),
                                  ]
                                ),
                                TableRow(
                                    children: [
                                      Text("Dropoff: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Text("Sharjah",style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.left,),
                                        ),
                                      ),
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Text("Distance: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Text("25 KM ",style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.left,),
                                        ),
                                      ),
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Text("Fare: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Text("70 AED ",style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.left,),
                                        ),
                                      ),
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Text("Estimated Time: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Text("22 Mins",style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.left,),
                                        ),
                                      ),
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Text("Instructions: ",style: TextStyle(color: AppColor.buttonColor,fontSize: 18,fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Text("Hello, you need to get me some bottles of Coca Cola from Super Mart. "
                                              "You have to buy some Lays also. I want it as soon as you can. So please hurry. "
                                              "If you still don't under stand then call me i will explain it to you.",
                                            style: TextStyle(color: Colors.black.withOpacity(0.6),fontSize: 17),textAlign: TextAlign.justify,),
                                        ),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: ButtonTheme(
                          height: 40,
                          minWidth: MediaQuery.of(context).size.width*0.4,
                          child: RaisedButton(
                            elevation: 10,
                            child: Text("Accept",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                            onPressed: (){

                            },
                            color: AppColor.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: AppColor.buttonColor),
                            ),

                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: ButtonTheme(
                          height: 40,
                          minWidth: MediaQuery.of(context).size.width*0.4,
                          child: RaisedButton(
                            elevation: 10,
                            child: Text("Reject",style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.buttonColor,fontSize: 18),),
                            onPressed: (){

                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: AppColor.buttonColor),
                            ),

                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


