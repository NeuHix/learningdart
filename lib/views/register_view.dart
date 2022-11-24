import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exception.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/utilities/showErrorDialog.dart';
import 'dart:developer' as dev show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  // late final TextEditingController _user_name;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      height: 20,
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        bool result =
                            await InternetConnectionChecker().hasConnection;
                        if (result) {
                          await AuthService.firebase().currentUser;
                          final email = _email.text;
                          final password = _password.text;
                          // final username = _user_name;

                          try {
                            await AuthService.firebase().createUser(
                              email: email,
                              password: password,
                            );
                            final user = AuthService.firebase().currentUser;
                            user?.reload();

                            if (user != null) {
                              await AuthService.firebase()
                                  .sendEmailVerification();
                              Fluttertoast.showToast(
                                  msg: "Verification link Sent!");
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  verifyEmailPage, (route) => false);
                            } else if (user == null) {
                              await showErrorDialog(context, "Something went wrong!");
                            }
                          } on WeakPasswordAuthException {
                            await showErrorDialog(context, "Weak Password");
                          } on InvalidEmailAuthException {
                            await showErrorDialog(context, "Invalid Email");
                          } on EmailAlreadyInUseAuthException {
                            try {
                              Fluttertoast.showToast(msg: "Logging in..");
                              AuthService.firebase().logIn(
                                email: email,
                                password: password,
                              );

                              final user = AuthService.firebase().currentUser;
                              if (user?.isEmailVerified == true) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    homePage, (route) => false);
                              } else {
                                await showErrorDialog(
                                    context, "Something Went Wrong");
                              }
                            } on WrongPasswordAuthException {
                              dev.log("Wrong Password");
                              showErrorDialog(context, "Wrong Password.");
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
