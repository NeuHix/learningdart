import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exception.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/utilities/showDialogs.dart';
import 'dart:developer' as dev show log;

import 'package:simple_connection_checker/simple_connection_checker.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _name;

  // late final TextEditingController _user_name;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Create an Account!'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Scaffold(
                  body: Column(children: [
                    // TextField(
                    //   controller: _user_name,
                    //   decoration: const InputDecoration(
                    //       hintText: 'Name'
                    //   ),
                    //   obscureText: true,
                    //   enableSuggestions: false,
                    //   autocorrect: false,
                    //
                    // ),
                    const SizedBox(
                      width: 400,
                      height: 30,
                    ),

                    SizedBox(
                      width: 300,
                      height: 55,
                      child: TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusColor: Colors.blue,
                          fillColor: Colors.blue,
                          label: Text("Email"),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        enableSuggestions: true,
                        autocorrect: false,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      width: 400,
                      height: 30,
                    ),

                    SizedBox(
                      width: 300,
                      height: 55,
                      child: TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusColor: Colors.blue,
                          fillColor: Colors.blue,
                          label: Text("Name"),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        enableSuggestions: true,
                        autocorrect: false,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      width: 400,
                      height: 20,
                    ),

                    SizedBox(
                      width: 300,
                      height: 80,
                      child: TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          hintText: 'Password max 15 characters',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          label: Text("Password"),
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        maxLength: 15,
                      ),
                    ),

                    const SizedBox(
                      width: 400,
                      height: 10,
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        showProgressDialog(context);
                        bool result = await SimpleConnectionChecker
                            .isConnectedToInternet();
                        if (result) {
                          // await AuthService.firebase().currentUser;
                          final email = _email.text;
                          final password = _password.text;
                          // final username = _user_name;
                          final name = _name.text;
                          try {
                            await AuthService.firebase().createUser(
                              email: email,
                              password: password,
                            );
                            final user = AuthService.firebase().currentUser;
                            await user?.reload();
                            await FirebaseAuth.instance.currentUser
                                ?.updateDisplayName(name);

                            if (user != null) {
                              await AuthService.firebase()
                                  .sendEmailVerification();
                              Navigator.of(context, rootNavigator: true).pop();
                              // Fluttertoast.showToast(
                              //     msg: "Verification link Sent!");
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  verifyEmailPage, (route) => false);
                            } else if (user == null) {
                              Navigator.of(context, rootNavigator: true).pop();
                              await showErrorDialog(
                                  context, "Something went wrong!");
                            }
                          } on WeakPasswordAuthException {
                            Navigator.of(context, rootNavigator: true).pop();
                            await showErrorDialog(context, "Weak Password");
                          } on InvalidEmailAuthException {
                            Navigator.of(context, rootNavigator: true).pop();
                            await showErrorDialog(context, "Invalid Email");
                          } on EmailAlreadyInUseAuthException {
                            try {
                              // Fluttertoast.showToast(msg: "Logging in..");
                              AuthService.firebase().logIn(
                                email: email,
                                password: password,
                              );

                              final user = AuthService.firebase().currentUser;
                              if (user?.isEmailVerified == true) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    NotesPage, (route) => false);
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                await showErrorDialog(
                                    context, "Something Went Wrong");
                              }
                            } on WrongPasswordAuthException {
                              dev.log("Wrong Password");
                              await showErrorDialog(context, "Wrong Password.");
                            }
                          } on GenericAuthException catch (e) {
                            await showErrorDialog(context, "${e.toString}");
                          }
                        } else {
                          if (!mounted) {}
                          showErrorDialog(context, "No Internet Connection");
                        }
                      },
                      child: const Text('Register as a New User'),
                    ),
                    const SizedBox(
                      width: 400,
                      height: 30,
                    ),

                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginPage, (route) => false);
                        },
                        child: const Text("Member? Come Here!"))
                  ]),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
