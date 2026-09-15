import 'dart:async';
import 'package:bizkonec/features/auth/domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthStatus>.broadcast();

  MockAuthRepository() {
    _controller.add(AuthStatus.authenticated); // Default for dev
  }

  @override
  Stream<AuthStatus> get status => _controller.stream;

  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _controller.add(AuthStatus.authenticated);
  }

  @override
  Future<void> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    _controller.add(AuthStatus.authenticated);
  }

  @override
  Future<void> logout() async {
    _controller.add(AuthStatus.unauthenticated);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
