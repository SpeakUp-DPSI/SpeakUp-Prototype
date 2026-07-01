import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/report_model.dart';

class ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSource(this.apiClient);

  Future<List<ReportModel>> getReports({String? search, String? status, String? category, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await apiClient.dio.get('/reports', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final responseData = response.data['data'];

        List<dynamic> list;
        if (responseData is Map && responseData.containsKey('data')) {
          list = responseData['data'] as List;
        } else if (responseData is List) {
          list = responseData;
        } else {
          list = [];
        }

        return list.map((json) => ReportModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<ReportModel> getReportById(int id) async {
    try {
      final response = await apiClient.dio.get('/reports/$id');
      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<ReportModel> createReport(Map<String, dynamic> data, {List<String>? filePaths}) async {
    try {
      if (filePaths != null && filePaths.isNotEmpty) {
        final formData = FormData.fromMap({...data});
        for (var path in filePaths) {
          formData.files.add(MapEntry(
            'evidences[]',
            await MultipartFile.fromFile(path),
          ));
        }
        final response = await apiClient.dio.post('/reports', data: formData);
        if (response.data['success'] == true) {
          return ReportModel.fromJson(response.data['data']);
        }
        throw Exception(response.data['message']);
      } else {
        final response = await apiClient.dio.post(
          '/reports',
          data: data,
          options: Options(contentType: 'application/json'),
        );
        if (response.data['success'] == true) {
          return ReportModel.fromJson(response.data['data']);
        }
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> updateStatus(int reportId, String status, {String? notes}) async {
    try {
      final response = await apiClient.dio.put(
        '/reports/$reportId/status',
        data: {
          'status': status,
          'notes': notes,
        },
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
