import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/enums/menu_actions.dart';
import 'package:learningdart/services/auth/auth_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  dev.log("No I wouldn't.");
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Fluttertoast.showToast(msg: "Cool! Now Login Again.");
                    if (!mounted) {}
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginPage,
                      (route) => false,
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "Never do that Again!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuActions>(
                  value: MenuActions.logout,
                  child: Text("Log Out"),
                )
              ];
            },
          )
        ],
      ),
      body: const Text("Wait a minute"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);

                /// Navigator is used to only focus on the dialog for the moment and
                /// nothing else
              },
              child: const Text("Yes, Log Out.")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No, Stay.")),
        ],
      );
    },
  ).then((value) => value ?? false);
}
