import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/mediation_model.dart';

class MediationRemoteDataSource {
  final ApiClient apiClient;

  MediationRemoteDataSource(this.apiClient);

  Future<List<MediationModel>> getMediationsByReport(int reportId) async {
    try {
      final response = await apiClient.dio.get('/reports/$reportId/mediations');
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => MediationModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<MediationModel> getMediationById(int id) async {
    try {
      final response = await apiClient.dio.get('/mediations/$id');
      if (response.data['success'] == true) {
        return MediationModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<MediationModel> createMediation(int reportId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        '/reports/$reportId/mediations',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      if (response.data['success'] == true) {
        return MediationModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<MediationModel> updateMediationStatus(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.put(
        '/mediations/$id/status',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      if (response.data['success'] == true) {
        return MediationModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
