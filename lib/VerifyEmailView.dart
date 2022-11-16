import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:learningdart/constants/routes.dart';

var status = "Not Verified";
void changeStatusToVerified() {
  status = "Verified";
}

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
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
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
                  final user = await FirebaseAuth.instance.currentUser;
                  await user?.reload();
                  dev.log(user.toString());
                  if (user?.emailVerified == true) {
                    changeStatusToVerified();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(homePage, (route) => false);
                  } else if (user?.emailVerified == false) {
                    changeStatusToNotVerified();
                  }
                },
                child: const Text("Refresh Status"))
          ],
        ));
  }
}
