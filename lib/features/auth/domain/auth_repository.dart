import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { authenticated, unauthenticated, initial }

abstract class AuthRepository {
  Stream<AuthStatus> get status;
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name);
  Future<void> logout();
  Future<void> resetPassword(String email);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Override this provider in the data layer');
});
