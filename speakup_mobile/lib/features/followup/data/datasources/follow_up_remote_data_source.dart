import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/follow_up_model.dart';

class FollowUpRemoteDataSource {
  final ApiClient apiClient;

  FollowUpRemoteDataSource(this.apiClient);

  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId) async {
    try {
      final response = await apiClient.dio.get('/reports/$reportId/follow-ups');
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list.map((json) => FollowUpModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<FollowUpModel> createFollowUp(int reportId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        '/reports/$reportId/follow-ups',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      if (response.data['success'] == true) {
        return FollowUpModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
