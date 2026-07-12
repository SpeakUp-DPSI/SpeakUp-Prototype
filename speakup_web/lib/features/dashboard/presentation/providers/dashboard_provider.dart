import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_stats_model.dart';

final dashboardDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSource(apiClient);
});

final dashboardRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(dashboardDataSourceProvider);
  return DashboardRepository(dataSource);
});

final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getStatistics();
});
