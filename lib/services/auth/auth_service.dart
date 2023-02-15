import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/auth_user.dart';
import 'package:learningdart/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(Authenticate(),);


  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    final User = provider.createUser(
      email: email,
      password: password,
    );
    return User;
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    provider.logOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    provider.sendEmailVerification();
  }

  @override
  Future<void> initialize() => provider.initialize();

}
