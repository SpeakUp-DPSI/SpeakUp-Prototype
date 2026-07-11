import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';
import '../models/admin_user_model.dart';

class DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSource(this.apiClient);

  Future<DashboardStatsModel> getStatistics() async {
    try {
      final response = await apiClient.dio.get('/dashboard/statistics');
      if (response.data['success'] == true) {
        return DashboardStatsModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}

// TODO: perlu endpoint backend belum tersedia — GET/POST/PUT/DELETE /api/admin/users
class AdminUserDataSource {
  final ApiClient apiClient;

  AdminUserDataSource(this.apiClient);

  Future<List<AdminUserModel>> getUsers() async {
    try {
      final response = await apiClient.dio.get('/admin/users');
      if (response.data['success'] == true) {
        final raw = response.data['data'];
        final list = raw is List
            ? raw
            : (raw is Map && raw['data'] is List ? raw['data'] : []);
        return (list as List)
            .map((j) => AdminUserModel.fromJson(j))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<AdminUserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/admin/users', data: data);
      if (response.data['success'] == true) {
        return AdminUserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat pengguna');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<AdminUserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response =
          await apiClient.dio.put('/admin/users/$id', data: data);
      if (response.data['success'] == true) {
        return AdminUserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal memperbarui pengguna');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await apiClient.dio.delete('/admin/users/$id');
      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Gagal menghapus pengguna');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
