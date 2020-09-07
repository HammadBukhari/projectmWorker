import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/view/HomePage.dart';
import 'package:projectmworker/view/OrderScreen.dart';

import 'provider/LoginProvider.dart';
import 'view/authentication/auth_screen.dart';
import 'view/provider/OrderProvider.dart';

Future<Widget> setup() async {
  GetIt.I.registerSingleton(LoginProvider());
  if (await GetIt.I<LoginProvider>().isUserLoggedIn) {
      GetIt.I.registerSingleton(OrderProvider());

    return HomePage();
  }

 return LoginScreen();
}
