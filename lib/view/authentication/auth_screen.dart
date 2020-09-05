import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmworker/provider/LoginProvider.dart';
import 'package:projectmworker/shared/color.dart';

import '../HomePage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  FocusNode _myNode;

  final provider = GetIt.I<LoginProvider>();

  final _emailKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();

  final TextEditingController emailTextController = TextEditingController();

  double getScreenWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width < 500)
      return MediaQuery.of(context).size.width;
    else
      return 500;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColor.primaryColor,
            body: Container(
              width: getScreenWidth(context),
              child: Center(
                child: Form(
                  key: _emailKey,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 90,
                      ),
                      Center(
                        child: Text(
                          "Hello Messenger",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: Text(
                          "Sign in using your email",
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xffffffff).withOpacity(0.80),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32.0,
                          right: 32,
                        ),
                        child: TextFormField(
                          focusNode: _myNode,
                          controller: emailTextController,
                          validator: MultiValidator([
                            EmailValidator(
                                errorText: 'Enter a valid email address'),
                            RequiredValidator(errorText: "Email is required"),
                          ]),
                          decoration: InputDecoration(
                            filled: true,
                            errorStyle: TextStyle(
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            hintText: "Email Address",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32.0,
                          right: 32,
                        ),
                        child: TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: 'password is required'),
                            MinLengthValidator(8,
                                errorText:
                                    'password must be at least 8 digits long'),
                            // PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                            //     errorText:
                            //         'passwords must have at least one special character')
                          ]),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Password",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppColor.primaryColor, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              "By continuing you accept our term of service"),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: RaisedButton(
                          onPressed: () async {
                            String emailText = emailTextController.text.trim();
                            String passwordText = passwordController.text;
                            if (_emailKey.currentState.validate()) {
                              FocusScope.of(context).unfocus();
                              final status = await provider.loginWithEmail(
                                  emailText, passwordText);
                              if (status == false) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Incorrect email/password or internet connection issue");
                              } else {
                                Get.to(HomePage());
                              }
                            }
                          },
                          shape: AppShape.buttonShape,
                          color: AppColor.buttonColor,
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
