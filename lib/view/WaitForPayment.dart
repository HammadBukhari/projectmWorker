import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:projectmworker/shared/color.dart';

class WaitPage extends StatefulWidget {
  @override
  _WaitPageState createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPage> {
  final loginProvider = GetIt.I<LoginProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.primaryColor,
              AppColor.buttonColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Hello ${loginProvider.messenger.uid}",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Waiting for payment to be done. ",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
