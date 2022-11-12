import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



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
        title:  Text('Verify Email'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          const SizedBox(
            width: 400,
            height: 30,
          ),


          Text('Click the thing below to get the verification link.'),
          const SizedBox(
            width: 400,
            height: 30,
          ),
          ElevatedButton(
              onPressed:  () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();

              },
              child: const Text("Send Link"),
          ),

          const SizedBox(
            width: 400,
            height: 100,
          ),

          Text("Status: $status"),

          ElevatedButton(
              onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  print(user);
                  if (user?.emailVerified == true) {
                      changeStatusToVerified();

                  }  else if (user?.emailVerified == false) {
                    changeStatusToNotVerified();
                    }
                  },
              child: const Text("Refresh Status")
          )
        ],
      )
    );

  }
}
