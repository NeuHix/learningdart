import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import '../utilities/child_dialogs.dart';
import '../utilities/generic_dialog.dart';
import 'dart:developer' as dev show log;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginView(),
    );
  }
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
          title: const Text('Enter Your Credentials!'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Scaffold(
                  body: Column(children: [
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
                        showProgressDialog(context);
                        bool result = await SimpleConnectionChecker
                            .isConnectedToInternet();

                        if (result) {
                          try {
                            await AuthService.firebase().initialize();
                            final email = _email.text;
                            final password = _password.text;

                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            // final user = await FirebaseAuth.instance.currentUser;

                            // var auth = FirebaseAuth.instance.authStateChanges();
                            // final authIsEmpty = await auth.isEmpty;
                            // final user = AuthService.firebase().currentUser;
                            // await user?.reload();

                            var user = await FirebaseAuth.instance
                                .authStateChanges()
                                .isEmpty;
                            dev.log("$user");
                            if (!user) {
                              Future.delayed(const Duration(seconds: 3), () {
                                var realUser =
                                    FirebaseAuth.instance.currentUser;
                                if (realUser != null) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, notesPage, (route) => false);
                                }
                              });
                            }

                          } on FirebaseAuthException catch (e) {
                              if (mounted) {
                                Navigator.of(context, rootNavigator: true).pop();
                                showErrorDialog(context, e.code);
                              }
                          }
                        } else {
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                            showErrorDialog(context, "No Internet Connection");
                          }
                        }
                      },
                      child: const Text('Login Now.'),
                    ),
                    const SizedBox(
                      width: 400,
                      height: 30,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              registerPage, (route) => false);
                        },
                        child: const Text("Don't have one? Create."))
                  ]),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
