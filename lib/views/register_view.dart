import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

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
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
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
                          hintText: 'Password max 9 characters',
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
                        maxLength: 9,
                      ),
                    ),
                    SizedBox(
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
                        // final username = _user_name;

                        try {
                          final userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'email-already-in-use') {
                            try {
                              Text('Emali Already in Use.');
                              FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: email, password: password);
                            } on FirebaseAuthException catch (t) {
                              print(e.code);
                              if (t.code == 'wrong-password') {
                                const Text('data');
                              }
                            }
                          } else if (e.code == 'weak-password') {
                            print('Weak password');
                          } else if (e.code == 'invalid-email') {
                            print('Invalid Email ');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong');
                          }
                        }
                      },
                      child: const Text('Register as a New User'),
                    ),

                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login/', (route) => false);
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
