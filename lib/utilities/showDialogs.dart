import 'package:flutter/material.dart';

Future<void> showErrorDialog (BuildContext context, String text) {
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: const Text("Here's what Happened..."),
      content: Text(text),
      actions: [

        TextButton(onPressed: () {
          Navigator.of(context).pop();
        },
          child: const Text("Okay!"),)


      ],
    );
  });
}

Future<void> showProgressDialog (BuildContext context) {
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
      content: const CircularProgressIndicator(),

      actions: [

        TextButton(onPressed: () {
          Navigator.of(context).pop();
        },
          child: const Text("Hide"),)
      ],
      contentPadding: const EdgeInsets.only(right: 125, left: 120,top: 40, bottom: 40),
    );
  });
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