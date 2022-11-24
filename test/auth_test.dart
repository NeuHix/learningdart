import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/auth_user.dart';
// import 'package:test/test.dart';

void main() {}

class MockAuthProvider implements AuthProvider {
  AuthUser? user;
  var _isInitialized = false;

  bool get isInitialized {
    return _isInitialized;
  }

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 2));

    return logIn(
      email: email,
      password: password,
    );
  }

  @override

  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) {

    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {

    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {

    throw UnimplementedError();
  }
}

class NotInitializedException implements Exception {}
