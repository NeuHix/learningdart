import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/firebase_options.dart';
import 'views/Login_View.dart';
import 'views/register_view.dart';

/// StatefulWidget are things that gonna be changed
/// during user interaction like the counter in here, changing texts etc.
///
/// StatelessWidget aren't gonna be changed during
/// user interaction like icon, buttons, text.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  MyApp.forDesignTime();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,

      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user  = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified == true) {
                print('WooHoo! Verifired Email.');
              } else {
                print('Fuck you bitch!');
              }
              return Text('Done.');
            default:
              return Text('Still Loading');
          }
        },
      ),
    );

  }
}








