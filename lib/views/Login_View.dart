import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import '../firebase_options.dart';


import '../utilities/showErrorDialog.dart';

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
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
          future:  Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform
          ),
          builder: (context, snapshot) {

            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Scaffold(
                  body: Column(
                      children: [

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
                                borderSide: BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 0.0),
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
                              hintText: 'Password max 9 characters',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 0.0),
                              ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
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
                            await Firebase.initializeApp(
                              options: DefaultFirebaseOptions.currentPlatform,
                            );
                            final email = _email.text;
                            final password = _password.text;

                            try {
                              await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

                              final user = FirebaseAuth.instance.currentUser;

                              if (user?.emailVerified == true) {
                                Navigator.of(context).pushNamedAndRemoveUntil(homePage, (route) => false);
                              } else if (user?.emailVerified == false) {
                                Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailPage, (route) => false);
                              }
                              // Future<UserCredential> userCredential;
                                  // FutureBuilder(
                                  //   future:
                                  //   builder: (BuildContext context,snapshot) {
                                  //     switch (snapshot.connectionState) {
                                  //       case ConnectionState.active:
                                  //         return const CircularProgressIndicator();
                                  //       // case ConnectionState.done:
                                  //       //   return
                                  //       default:
                                  //         return const CircularProgressIndicator();
                                  //     }
                                  //   }
                                  //   ,
                                  // );
                            } on FirebaseAuthException catch (e) {

                              switch (e.code) {
                                case 'wrong-password':
                                  await showErrorDialog(context, "Wrong Password");
                                  break;
                                case 'user-not-found':
                                  await showErrorDialog(context, "Unknown Username");
                                  break;
                                default:
                                  await showErrorDialog(context, e.code);

                              }
                            } catch (e) {
                              await showErrorDialog(context, e.toString());
                            }


                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green,), //button color
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text('Login Now.'),
                        ),

                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(registerPage, (route) => false);
                          },

                            child: const Text("Don't have one? Create.")

                        )
                      ]
                  ),
                );
              default:
                return const CircularProgressIndicator();
            }
          },

        )

    );
  }
}















