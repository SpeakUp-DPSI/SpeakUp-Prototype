import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';

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
