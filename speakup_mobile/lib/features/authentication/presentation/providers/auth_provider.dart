import 'dart:convert';
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
  @override
  AuthState build() {
    _checkAuth();
    return AuthInitial();
  }

  Future<void> _checkAuth() async {
    final tokenManager = ref.read(tokenManagerProvider);
    final token = await tokenManager.getToken();
    if (token != null) {
      // Coba restore user data yang sudah disimpan saat login
      final userDataJson = await tokenManager.getUserData();
      if (userDataJson != null) {
        try {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          state = AuthSuccess(UserModel.fromJson(userData));
          return;
        } catch (_) {
          // JSON rusak — fallback ke default siswa
        }
      }
      // Fallback: jika tidak ada data user tersimpan
      state = AuthSuccess(
        UserModel(
          id: 1,
          name: 'User (Mock Session)',
          email: 'user@speakup.com',
          roles: ['siswa'],
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Bypass Logic: Tentukan role berdasarkan isi email
    List<String> roles = ['siswa']; // default
    String name = 'Siswa Demo';

    final e = email.toLowerCase();
    if (e.contains('admin')) {
      roles = ['admin'];
      name = 'Admin Demo';
    } else if (e.contains('kepsek') || e.contains('principal')) {
      roles = ['kepsek'];
      name = 'Kepala Sekolah Demo';
    } else if (e.contains('guru') || e.contains('bk') || e.contains('teacher')) {
      roles = ['guru_bk'];
      name = 'Guru BK Demo';
    } else if (e.contains('ortu') || e.contains('parent') || e.contains('wali')) {
      roles = ['orangtua'];
      name = 'Orang Tua Demo';
    }

    final mockUser = UserModel(
      id: 99,
      name: name,
      email: email,
      roles: roles,
      phone: '08123456789',
    );

    final tokenManager = ref.read(tokenManagerProvider);
    await tokenManager.saveToken('mock_token_12345');
    // Simpan user data supaya role tetap benar saat refresh/reload
    await tokenManager.saveUserData(jsonEncode(mockUser.toJson()));
    state = AuthSuccess(mockUser);
  }

  Future<void> logout() async {
    state = AuthLoading();
    final tokenManager = ref.read(tokenManagerProvider);
    await tokenManager.removeToken();
    await tokenManager.removeUserData();
    state = AuthInitial();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    // Mock bypass update
    if (state is AuthSuccess) {
      final user = (state as AuthSuccess).user;
      final updatedUser = UserModel(
        id: user.id,
        name: data['name'] ?? user.name,
        email: data['email'] ?? user.email,
        roles: user.roles,
        phone: data['phone'] ?? user.phone,
      );
      state = AuthSuccess(updatedUser);
      // Persist updated user data
      final tokenManager = ref.read(tokenManagerProvider);
      await tokenManager.saveUserData(jsonEncode(updatedUser.toJson()));
    }
  }

  Future<void> refreshProfile() async {
    // Silently fail on mock
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
