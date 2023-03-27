import 'package:flutter/material.dart';

Future<dynamik?> genericDialog<dynamik> ({
  required BuildContext context,
  required String title,
  required String text,
  required Map listOfActions,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: listOfActions.keys.map((listOfActionsTitle) {
            final value = listOfActions[listOfActionsTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(listOfActionsTitle),
            );
          }
      ).toList());
    },
  );
}

Future<void> showProgressDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const CircularProgressIndicator(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hide"),
            )
          ],
          contentPadding:
          const EdgeInsets.only(right: 125, left: 120, top: 40, bottom: 40),
        );
      });
}