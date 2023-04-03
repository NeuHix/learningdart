import 'package:flutter/material.dart';
import 'package:learningdart/utilities/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return genericDialog(
      context: context,
      title: "Error!",
      text: text,
      listOfActions: {"fine!": null});
}

Future<bool> showLogOutDialog(BuildContext context) {
  return genericDialog(
    context: context,
    title: "Log Out?",
    text: "Are you sure you wanna log out?",
    listOfActions: {"yep!": true, "nope!": false},
  ).then((value) => value ?? false);
}

Future<bool> showDeleteDialog(BuildContext context) {
  return genericDialog(
    context: context,
    title: "Delete Note?",
    text: "Are you sure ?",
    listOfActions: {"yes!": true, "stop!": false},
  ).then((value) => value ?? false);
}
