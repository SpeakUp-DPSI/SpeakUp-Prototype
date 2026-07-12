import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/models/admin_user_model.dart';

final adminUsersProvider = AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserModel>>(() {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserModel>> {
  @override
  Future<List<AdminUserModel>> build() async {
    return _fetchUsers();
  }

  Future<List<AdminUserModel>> _fetchUsers() async {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.dio.get('/users');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((u) => AdminUserModel.fromJson(u))
            .toList();
      }
    }
    throw Exception('Failed to load users');
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<bool> updateUserRole(int userId, String newRole) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.dio.put(
        '/users/$userId/role',
        data: {'role': newRole},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          ref.invalidateSelf();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createUser(String name, String email, String password, String phone, String role) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.dio.post(
        '/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser(int userId, String name, String email, String phone) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.dio.put(
        '/users/$userId',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
        },
      );
      if (response.statusCode == 200) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.dio.delete('/users/$userId');
      if (response.statusCode == 200) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}


