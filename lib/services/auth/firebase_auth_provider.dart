import 'dart:developer' as dev show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:learningdart/firebase_options.dart';
import 'package:learningdart/services/auth/auth_user.dart';
import 'package:learningdart/services/auth/auth_exception.dart';
import 'package:learningdart/services/auth/auth_provider.dart';

class Authenticate implements AuthProvider {
  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,);

      return currentUser;
  }

  @override
  AuthUser? get currentUser  {
    final user =  FirebaseAuth.instance.currentUser;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    user?.reload();
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return AuthUser.fromFirebase(user);
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotLoggedInAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }

  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else if (user == null) {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      user.sendEmailVerification();
      dev.log("Verification Email Sent Successfully");
      // Fluttertoast.showToast(msg: "Verification Email Sent!");
    } else if (user == null) {
      dev.log("User is Null");
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
      );
    }


  }
}