import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../report/data/models/report_model.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final reportsAsync = ref.watch(reportsListProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: isDesktop ? null : AppBar(
        title: const Text('Dashboard Orang Tua', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(reportsListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: isDesktop
              ? _buildDesktopContent(statsAsync, reportsAsync, context)
              : _buildMobileContent(statsAsync, reportsAsync, context),
        ),
      ),
    );
  }

  // ─── Desktop Content ─────────────────────────────────────────────────
  Widget _buildDesktopContent(AsyncValue statsAsync, AsyncValue reportsAsync, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Hero Banner ──────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.primary600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.family_restroom, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pantau Laporan Anak',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lihat status laporan dan jadwal mediasi yang melibatkan anak Anda.\nKami berkomitmen untuk menjaga keamanan anak Anda di lingkungan sekolah.',
                      style: TextStyle(fontSize: 14, color: AppTheme.primary100, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ─── Two-column: Stats + Reports ──────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Stats Row ──────
                  const Text('Ringkasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => EmptyStateWidget(
                      icon: Icons.cloud_off, title: 'Gagal memuat data',
                      subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                      iconColor: AppTheme.danger600,
                    ),
                    data: (stats) => Row(
                      children: [
                        _buildStatCard('Total Laporan', '${stats.total}', AppTheme.primary600),
                        const SizedBox(width: 12),
                        _buildStatCard('Selesai', '${stats.completed}', AppTheme.success600),
                        const SizedBox(width: 12),
                        _buildStatCard('Diproses', '${stats.processing}', AppTheme.info600),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Reports Table ──────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neutral100),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Laporan Terkini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                              TextButton(
                                onPressed: () => context.go('/reports'),
                                child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primary600)),
                              ),
                            ],
                          ),
                        ),
                        // Table header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.neutral50,
                            border: Border(
                              top: BorderSide(color: AppTheme.neutral100),
                              bottom: BorderSide(color: AppTheme.neutral100),
                            ),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 44 + 10),
                              Expanded(flex: 2, child: Text('Kode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.neutral500))),
                              Expanded(flex: 3, child: Text('Judul', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.neutral500))),
                              SizedBox(width: 100, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.neutral500))),
                            ],
                          ),
                        ),
                        reportsAsync.when(
                          loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                          error: (err, stack) => EmptyStateWidget(
                            icon: Icons.cloud_off, title: 'Gagal memuat laporan',
                            subtitle: 'Tarik ke bawah untuk mencoba lagi.', iconColor: AppTheme.danger600,
                          ),
                          data: (reports) {
                            if (reports.isEmpty) {
                              return EmptyStateWidget(
                                icon: Icons.inbox_outlined, title: 'Belum ada laporan',
                                subtitle: 'Laporan dari anak Anda akan muncul di sini.', iconColor: AppTheme.neutral400,
                              );
                            }
                            return Column(
                              children: reports.take(7).map((r) => _buildReportRow(r, context)).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Sidebar
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neutral100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline, color: AppTheme.primary600, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text('Informasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutral900)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _infoItem(Icons.shield_outlined, 'Identitas pelapor dijamin kerahasiaannya'),
                        _infoItem(Icons.access_time, 'Laporan ditangani dalam 1x24 jam'),
                        _infoItem(Icons.support_agent, 'Konselor siap mendampingi anak Anda'),
                        _infoItem(Icons.verified_user_outlined, 'Proses transparan dan termonitor'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contact Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.phone_outlined, color: AppTheme.primary600, size: 20),
                            SizedBox(width: 8),
                            Text('Butuh Bantuan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Hubungi Guru BK atau Admin sekolah jika ada pertanyaan terkait laporan anak Anda.',
                          style: TextStyle(fontSize: 12, color: AppTheme.neutral600, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary600),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.neutral600, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildReportRow(ReportModel report, BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    return InkWell(
      onTap: () => context.push('/report/${report.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.neutral100)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.assignment, color: statusColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.neutral900))),
            Expanded(flex: 3, child: Text(report.title, style: const TextStyle(fontSize: 12, color: AppTheme.neutral600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            SizedBox(
              width: 100,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(_formatStatus(report.status), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mobile Content ──────────────────────────────────────────────────
  Widget _buildMobileContent(AsyncValue statsAsync, AsyncValue reportsAsync, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.family_restroom, size: 48, color: Colors.white54),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pantau Laporan Anak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Lihat status laporan dan jadwal mediasi yang melibatkan anak Anda.', style: TextStyle(fontSize: 14, color: AppTheme.primary100)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
        const SizedBox(height: 16),
        statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => EmptyStateWidget(icon: Icons.cloud_off, title: 'Gagal memuat data', subtitle: 'Tarik ke bawah untuk mencoba lagi.', iconColor: AppTheme.danger600),
          data: (stats) => Row(
            children: [
              _buildStatCard('Total Laporan', '${stats.total}', AppTheme.primary600),
              const SizedBox(width: 16),
              _buildStatCard('Selesai', '${stats.completed}', AppTheme.success600),
              const SizedBox(width: 16),
              _buildStatCard('Diproses', '${stats.processing}', AppTheme.info600),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Laporan Terkini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
            TextButton(
              onPressed: () => context.go('/reports'),
              child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primary600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => EmptyStateWidget(icon: Icons.cloud_off, title: 'Gagal memuat laporan', subtitle: 'Tarik ke bawah untuk mencoba lagi.', iconColor: AppTheme.danger600),
          data: (reports) {
            if (reports.isEmpty) {
              return EmptyStateWidget(icon: Icons.inbox_outlined, title: 'Belum ada laporan', subtitle: 'Laporan dari anak Anda akan muncul di sini.', iconColor: AppTheme.neutral400);
            }
            return Column(children: reports.take(5).map((r) => _buildReportItem(r, context)).toList());
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(ReportModel report, BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: ListTile(
        onTap: () => context.push('/report/${report.id}'),
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.assignment, color: statusColor),
        ),
        title: Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(_formatStatus(report.status), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation': return 'Menunggu';
      case 'processing': return 'Diproses';
      case 'mediation': return 'Mediasi';
      case 'follow_up': return 'Tindak Lanjut';
      case 'completed': return 'Selesai';
      case 'rejected': return 'Ditolak';
      default: return 'Terkirim';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting_validation': return AppTheme.warning600;
      case 'processing': return AppTheme.info600;
      case 'completed': return AppTheme.success600;
      case 'rejected': return AppTheme.danger600;
      default: return AppTheme.neutral500;
    }
  }
}
