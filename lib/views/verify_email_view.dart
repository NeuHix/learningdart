import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';

var status = "Not Verified";
void changeStatusToVerified() {
  status = "Verified";
}

/// changes status to verified based on status
///
/// your are the boos
void changeStatusToNotVerified() {
  status = "Not Verified";
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
          backgroundColor: Colors.amber,
        ),
        body: Column(
          children: [
            const SizedBox(
              width: 400,
              height: 30,
            ),
            const Text(
                "We've sent you the email verification link. Please verify."),
            const SizedBox(
              width: 400,
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text("Send Link Again."),
            ),
            const SizedBox(
              width: 400,
              height: 100,
            ),
            Text("Status: $status"),
            ElevatedButton(
                onPressed: () async {
                  final user = AuthService.firebase().currentUser;
                  await user?.reload();
                  dev.log(user.toString());
                  if (user?.isEmailVerified == true) {
                    changeStatusToVerified();
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(notesPage, (route) => false);
                    }
                  } else if (user?.isEmailVerified == false) {
                    changeStatusToNotVerified();
                  }
                },
                child: const Text("Refresh Status")),
          ],
        ));
  }
}
