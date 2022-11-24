import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final bool isAnonymous;

  Future<void> reload() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }

  const AuthUser({
    required this.isEmailVerified,
    required this.isAnonymous,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        isAnonymous: user.isAnonymous,
      );
}
