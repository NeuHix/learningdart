import 'package:flutter/material.dart';
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
      home: const RegisterView(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}








