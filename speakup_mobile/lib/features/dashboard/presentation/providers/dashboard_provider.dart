import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/models/admin_user_model.dart';

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

// ─── Admin User providers ─────────────────────────────────────────────────────
// TODO: perlu endpoint backend belum tersedia — /api/admin/users

final adminUserDataSourceProvider = Provider<AdminUserDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminUserDataSource(apiClient);
});

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserModel>> {
  @override
  Future<List<AdminUserModel>> build() async {
    final ds = ref.read(adminUserDataSourceProvider);
    return await ds.getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(adminUserDataSourceProvider);
      return await ds.getUsers();
    });
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    final ds = ref.read(adminUserDataSourceProvider);
    final created = await ds.createUser(data);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final ds = ref.read(adminUserDataSourceProvider);
    final updated = await ds.updateUser(id, data);
    state = AsyncData(
      state.value?.map((u) => u.id == id ? updated : u).toList() ?? [],
    );
  }

  Future<void> deleteUser(int id) async {
    final ds = ref.read(adminUserDataSourceProvider);
    await ds.deleteUser(id);
    state = AsyncData(
      state.value?.where((u) => u.id != id).toList() ?? [],
    );
  }
}

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserModel>>(
  AdminUsersNotifier.new,
);
