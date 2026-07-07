import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDataSourceProvider);
  final tokenManager = ref.read(tokenManagerProvider);
  return AuthRepository(remote, tokenManager);
});

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _checkAuth();
    return AuthInitial();
  }

  Future<void> _checkAuth() async {
    final token = await ref.read(tokenManagerProvider).getToken();
    if (token != null) {
      try {
        state = AuthLoading();
        final user = await _repository.getProfile();
        state = AuthSuccess(user);
      } catch (e) {
        await ref.read(tokenManagerProvider).removeToken();
        state = AuthInitial();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();

    try {
      final user = await _repository.login(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthLoading();
    try {
      await _repository.logout();
      state = AuthInitial();
    } catch (e) {
      state = AuthInitial();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _repository.updateProfile(data);
      state = AuthSuccess(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _repository.getProfile();
      state = AuthSuccess(user);
    } catch (e) {
      // Silently fail on refresh
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
