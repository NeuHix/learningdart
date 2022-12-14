import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/views/LandingView.dart';
import 'VerifyEmailView.dart';
import 'package:learningdart/views/Login_View.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/constants/routes.dart';
import 'dart:developer' as dev show log;

/*
StatefulWidget are things that gonna be changed
during user interaction like the counter in here, changing texts etc.
-->
StatelessWidget aren't gonna be changed during
user interaction like icon, buttons, text.
 */

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Master(),
      routes: {
        loginPage: (context) => const LoginView(),
        registerPage: (context) => const RegisterView(),
        homePage: (context) => const LandingPage(),
        verifyEmailPage: (context) => const VerifyEmailView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class Master extends StatelessWidget {
  const Master({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('HomePage'),
      // ),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              dev.log(user.toString());
              if (user?.isEmailVerified == true) {
                return const LandingPage();
              } else if (user?.isEmailVerified == false) {
                dev.log(user.toString());
                return const VerifyEmailView();
              } else if (user?.isAnonymous == null) {
                dev.log(user.toString());
                return const RegisterView();
              } else {
                dev.log(user.toString());
                return const LoginView();
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
