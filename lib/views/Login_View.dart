
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
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
        ),
        body: FutureBuilder(
          future:  Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform
          ),
          builder: (context, snapshot) {

            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
                    children: [
                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                            hintText: 'Email'

                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        autofillHints: ['@duck.com','@gmail.com'],

                        enableSuggestions: true,
                        autocorrect: false,
                      ),
                      TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                            hintText: 'Paasword'
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,

                      ),

                      TextButton(
                        onPressed: () async {
                          await Firebase.initializeApp(
                            options: DefaultFirebaseOptions.currentPlatform,
                          );
                          final email = _email.text;
                          final password = _password.text;

                          try {
                            final userCredential = await
                            FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email,
                                password: password);
                          } on FirebaseAuthException catch (e) {
                            FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                          } catch (f) {
                            print(f);
                          }


                        },
                        child: const Text('Login Now.'),
                      ),
                    ]
                );
              default:
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Check Intenet!"),
                  ),
                );
            }


          },

        )

    );
  }



}