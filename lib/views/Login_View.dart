import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exception.dart';
import 'package:learningdart/services/auth/auth_service.dart';
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
                        bool result = await InternetConnectionChecker()
                            .hasConnection;
                        if (result) {
                          await AuthService.firebase().initialize();
                          final email = _email.text;
                          final password = _password.text;

                          try {
                            await AuthService.firebase()
                                .logIn(email: email, password: password);

                            final user = AuthService
                                .firebase()
                                .currentUser;
                            user?.reload;
                            if (user?.isEmailVerified == true) {
                              if (!mounted) {}
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  homePage, (route) => false);
                            } else if (user?.isEmailVerified == false) {
                              if (!mounted) {}
                              AuthService.firebase().sendEmailVerification();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  verifyEmailPage, (route) => false);
                            }
                          } on WrongPasswordAuthException {
                            if (!mounted) {}
                            showErrorDialog(context, "Wrong Password");
                          } on UserNotFoundAuthException {
                            if (!mounted) {}
                            showErrorDialog(context, "User not found");
                          }
                        } else {
                          if (!mounted) {}
                          showErrorDialog(context, "No Internet Connection");
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green,
                        ), //button color
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Login Now.'),
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
        )
    );
  }
}
