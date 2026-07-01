import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        return {
          'token': response.data['data']['token'],
          'user': UserModel.fromJson(response.data['data']['user']),
        };
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/logout');
    } catch (_) {
      // Ignore logout errors
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/profile');
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.put('/profile', data: data);
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    try {
      await apiClient.dio.put('/profile/password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
