import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/report_remote_data_source.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report_model.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReportRemoteDataSource(apiClient);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remote = ref.read(reportRemoteDataSourceProvider);
  return ReportRepository(remote);
});

final reportsProvider = FutureProvider.autoDispose<List<ReportModel>>((ref) async {
  final repository = ref.read(reportRepositoryProvider);
  return await repository.getReports();
});

final reportDetailProvider = FutureProvider.autoDispose.family<ReportModel?, int>((ref, id) async {
  final repository = ref.read(reportRepositoryProvider);
  try {
    return await repository.getReportById(id);
  } catch (_) {
    return null;
  }
});

class ReportSearchNotifier extends Notifier<List<ReportModel>> {
  Timer? _debounce;

  @override
  List<ReportModel> build() {
    return [];
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        state = [];
        return;
      }
      try {
        final repository = ref.read(reportRepositoryProvider);
        final results = await repository.getReports(search: query);
        state = results;
      } catch (_) {
        state = [];
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = [];
  }
}

final reportSearchProvider = NotifierProvider<ReportSearchNotifier, List<ReportModel>>(() {
  return ReportSearchNotifier();
});

class CreateReportNotifier extends AsyncNotifier<ReportModel?> {
  @override
  FutureOr<ReportModel?> build() {
    return null;
  }

  Future<ReportModel?> create(Map<String, dynamic> data, {List<String>? filePaths}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(reportRepositoryProvider);
      final created = await repository.createReport(data, filePaths: filePaths);
      ref.invalidate(reportsProvider);
      state = AsyncData(created);
      return created;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final createReportProvider = AsyncNotifierProvider<CreateReportNotifier, ReportModel?>(() {
  return CreateReportNotifier();
});
