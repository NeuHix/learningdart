import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:fluttertoast/fluttertoast.dart';

enum Actions {
  logout,
  yes,
  no,
}

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
          PopupMenuButton(onSelected: (value) async {
              switch (value) {
                case Actions.logout:
                  print("No I wouldn't.");
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login/',
                          (route) => false,);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Never do that Again!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                  break;
              }
          },itemBuilder: (context) {
            return const [
              PopupMenuItem<Actions>(value:
              Actions.logout,
                child: Text("Log Out"),)
            ];
          },)
        ],
      ),
        body: const Text("Wait a minute minut"),
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
            TextButton(onPressed: () {
              Navigator.of(context).pop(true); /// Navigator is used to only focus on the dialog for the moment and
              /// nothing else
            }, child: const Text("Yes, Log Out.")),
            TextButton(onPressed: () {
              Navigator.of(context).pop(false);
            }, child: const Text("No, Stay.")),
    ],
  );
},
).then((value) => value ?? false);
}
