import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../report/presentation/providers/report_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.neutral700),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: AppTheme.primary100,
            child: Icon(Icons.person, color: AppTheme.primary600),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(reportsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CTA Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Berani Melapor!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Identitas kamu dijamin kerahasiaannya jika menggunakan fitur anonim.',
                            style: TextStyle(fontSize: 14, color: AppTheme.primary100),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => GoRouter.of(context).push('/report/create'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary600,
                            ),
                            child: const Text('Buat Laporan'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.shield, size: 80, color: Colors.white54),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Aksi Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionCard('Lapor', Icons.report_problem, AppTheme.danger600,
                      () => context.push('/report/create')),
                  const SizedBox(width: 16),
                  _buildActionCard('Riwayat', Icons.history, AppTheme.warning600,
                      () => context.push('/reports')),
                  const SizedBox(width: 16),
                  _buildActionCard('Profil', Icons.person_outline, AppTheme.info600,
                      () => context.push('/profile')),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Aktivitas Terkini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
              ),
              const SizedBox(height: 16),
              reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Gagal memuat data',
                  subtitle: 'Tarik ke bawah untuk mencoba lagi.',
                  iconColor: AppTheme.danger600,
                ),
                data: (reports) {
                  if (reports.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'Belum ada laporan',
                      subtitle: 'Mulai laporkan kasus perundungan untuk membantu menciptakan lingkungan sekolah yang aman.',
                      actionLabel: 'Buat Laporan',
                      onAction: () => context.push('/report/create'),
                    );
                  }
                  return Column(
                    children: reports.take(5).map((r) => _buildActivityItem(
                      r.reportCode,
                      _formatStatus(r.status),
                      _getStatusColor(r.status),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.neutral300),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String code, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.assignment, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: statusColor, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation': return 'Menunggu Validasi';
      case 'processing': return 'Sedang Diproses';
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
