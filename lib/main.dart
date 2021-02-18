import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'locator.dart';
import 'shared/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(
      screen: await setup(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget screen;

  const MyApp({Key key, this.screen}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      title: 'Messenger Workers',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: Colors.white,
          ),
          headline1: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          errorStyle: TextStyle(
            color: Colors.white,
          ),
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
        // primarySwatch: Colors.purple,
        primaryColor: AppColor.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: screen,
    );
  }
}
