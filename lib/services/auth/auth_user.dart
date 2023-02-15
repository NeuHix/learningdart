import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable

/// Making a Class named AuthUser.
class AuthUser {
  /// It has a property named 'email'.
  /// [final] meaning -> it's value isn't gonna be changed in the future.
  final String? email;

  /// Yet another property named  [isEmailVerified] which has a [bool] value.
  final bool isEmailVerified;

  /// Yet another property named  [isAnonymous] which has a [bool] value.
  final bool isAnonymous;

  /// A Reload Function for reloading current user's credentials from Firebase.
  /// * Future<void> -> It won't return anything in the future
  /// * reload() -> Name of the function.
  /// * async -> it's an asynchronous task. it'll take some time to complete
  /// * await -> this code would take sometime to be fully executed so wait for it's result.
  Future<void> reload() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }

  /// Demanding some values.
  const AuthUser({
    /// This function is a Constructor.
    /// In fact any function which named after its class_s' name is a Constructor.
    /// It is used to take the values of these properties(inside {}) if the class is used anywhere.
    required this.email,

    /// After taking the value of 'email', it will assign the value to class_s' 'email' field.
    required this.isEmailVerified,

    /// After taking the value of 'isEmailVerified', it will assign the value to class_s' 'isEmailVerified' field.
    required this.isAnonymous,

    /// After taking the value of 'isAnonymous', it will assign the value to class_s' 'isAnonymous' field.
  });

  /// Add Description to Constructor 'AuthUser.fromFirebase'
  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        isAnonymous: user.isAnonymous,
        email: user.email,
      );
}
