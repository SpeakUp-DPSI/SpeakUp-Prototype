import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../report/data/models/report_model.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru BK', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(reportsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Laporan',
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
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Menunggu Validasi', '${stats.valid}', AppTheme.warning600),
                        const SizedBox(width: 16),
                        _buildStatCard('Sedang Mediasi', '${stats.mediation}', AppTheme.info600),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard('Selesai', '${stats.completed}', AppTheme.success600),
                        const SizedBox(width: 16),
                        _buildStatCard('Total', '${stats.total}', AppTheme.primary600),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perlu Divalidasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
                  ),
                  TextButton(
                    onPressed: () => context.push('/reports'),
                    child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primary600)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.cloud_off,
                  title: 'Gagal memuat laporan',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (reports) {
                  final pendingReports = reports.where((r) => r.status == 'waiting_validation').take(5).toList();
                  if (pendingReports.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.check_circle_outline,
                      title: 'Belum ada laporan masuk',
                      subtitle: 'Laporan baru dari siswa akan muncul di sini.',
                      iconColor: AppTheme.success600,
                    );
                  }
                  return _buildReportList(pendingReports, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral300),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.neutral500)),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(List<ReportModel> reports, BuildContext context) {
    return Column(
      children: reports.map((report) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.neutral300),
          ),
          child: InkWell(
            onTap: () => context.push('/report/${report.id}'),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warning100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_late, color: AppTheme.warning600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(report.title, style: const TextStyle(color: AppTheme.neutral700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.neutral500),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
