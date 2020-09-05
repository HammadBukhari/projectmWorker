import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'provider/LoginProvider.dart';
import 'view/authentication/auth_screen.dart';


Future<Widget> setup() async {
  GetIt.I.registerSingleton(LoginProvider());
  if (await GetIt.I<LoginProvider>().isUserLoggedIn){
    
  }
  return LoginScreen();
}
