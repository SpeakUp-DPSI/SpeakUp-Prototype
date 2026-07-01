import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class PrincipalDashboardScreen extends ConsumerWidget {
  const PrincipalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kepala Sekolah', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardStatsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Eksekutif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
              ),
              const SizedBox(height: 16),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat statistik',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (stats) {
                  if (stats.total == 0) {
                    return EmptyStateWidget(
                      icon: Icons.bar_chart,
                      title: 'Belum ada data statistik',
                      subtitle: 'Statistik akan muncul ketika siswa mulai membuat laporan.',
                    );
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard('Total Laporan', '${stats.total}', AppTheme.primary600, Icons.bar_chart),
                          const SizedBox(width: 16),
                          _buildStatCard('Selesai', '${stats.completed}', AppTheme.success600, Icons.check_circle_outline),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard('Sedang Diproses', '${stats.processing}', AppTheme.info600, Icons.sync),
                          const SizedBox(width: 16),
                          _buildStatCard('Menunggu Validasi', '${stats.valid}', AppTheme.warning600, Icons.warning_amber),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard('Hari Ini', '${stats.today}', AppTheme.primary600, Icons.today),
                          const SizedBox(width: 16),
                          _buildStatCard('Bulan Ini', '${stats.thisMonth}', AppTheme.info600, Icons.calendar_month),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.neutral300),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Insiden',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
                    ),
                    const SizedBox(height: 24),
                    EmptyStateWidget(
                      icon: Icons.show_chart,
                      title: 'Belum ada data',
                      subtitle: 'Grafik tren laporan akan muncul di sini.',
                      iconColor: AppTheme.neutral400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.neutral700)),
          ],
        ),
      ),
    );
  }
}
