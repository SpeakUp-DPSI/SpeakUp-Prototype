import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/validation_model.dart';

class ValidationRemoteDataSource {
  final ApiClient apiClient;

  ValidationRemoteDataSource(this.apiClient);

  Future<List<ValidationModel>> getValidationsByReport(int reportId) async {
    try {
      final response = await apiClient.dio.get('/reports/$reportId/validations');
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => ValidationModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<ValidationModel> createValidation(int reportId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        '/reports/$reportId/validations',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      if (response.data['success'] == true) {
        return ValidationModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
