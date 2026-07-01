import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/report_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  final int id;

  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(id));
    final authState = ref.watch(authProvider);
    final isTeacher = authState is AuthSuccess && authState.user.roles.contains('guru_bk');
    final isAdmin = authState is AuthSuccess && authState.user.roles.contains('admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Gagal memuat laporan',
          subtitle: err.toString(),
          iconColor: AppTheme.danger600,
        ),
        data: (report) {
          if (report == null) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: 'Laporan tidak ditemukan',
              subtitle: 'Laporan dengan ID ini tidak tersedia atau telah dihapus.',
              iconColor: AppTheme.neutral400,
            );
          }

          final statusColor = _getStatusColor(report.status);
          final statusLabel = _formatStatus(report.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 16),
                Text(report.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(4)),
                      child: Text(report.reportCode, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    if (report.category != null)
                      Text('• ${report.category}', style: const TextStyle(color: AppTheme.neutral500)),
                  ],
                ),
                if (report.isAnonymous) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.security, size: 16, color: AppTheme.primary600),
                      SizedBox(width: 8),
                      Text('Dilaporkan secara Anonim', style: TextStyle(color: AppTheme.primary600, fontSize: 12)),
                    ],
                  )
                ],
                const SizedBox(height: 24),
                const Text('Kronologi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(report.description, style: const TextStyle(height: 1.6, color: AppTheme.neutral700)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (report.incidentDate != null)
                      _buildInfoItem(Icons.calendar_today, report.incidentDate!),
                    if (report.incidentDate != null && report.incidentLocation != null)
                      const SizedBox(width: 24),
                    if (report.incidentLocation != null)
                      _buildInfoItem(Icons.location_on, report.incidentLocation!),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Timeline Penanganan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTimelineItem('Laporan Masuk', 'Laporan berhasil dibuat dan tercatat.', true, isLast: report.status == 'submitted'),
                if (report.status != 'submitted') ...[
                  _buildTimelineItem(statusLabel, _getStatusDescription(report.status), true, isLast: true),
                ],
                const SizedBox(height: 48),
                if ((isTeacher || isAdmin) && report.status == 'waiting_validation') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Aksi Validasi (Guru BK)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleStatusUpdate(context, ref, report.id, 'rejected'),
                          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger600, side: const BorderSide(color: AppTheme.danger600)),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleStatusUpdate(context, ref, report.id, 'processing'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success600),
                          child: const Text('Validasi & Proses'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, WidgetRef ref, int reportId, String newStatus) async {
    try {
      final dataSource = ref.read(reportRemoteDataSourceProvider);
      await dataSource.updateStatus(reportId, newStatus);
      ref.invalidate(reportDetailProvider(reportId));
      ref.invalidate(reportsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Status berhasil diubah menjadi ${_formatStatus(newStatus)}'),
          backgroundColor: newStatus == 'rejected' ? AppTheme.danger600 : AppTheme.success600,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: AppTheme.danger600,
        ));
      }
    }
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.neutral500),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.neutral700)),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.primary600 : AppTheme.neutral300,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppTheme.primary600),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? AppTheme.neutral900 : AppTheme.neutral500)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.neutral500)),
                ],
              ),
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

  String _getStatusDescription(String status) {
    switch (status) {
      case 'waiting_validation': return 'Laporan sedang direview oleh Guru BK.';
      case 'processing': return 'Guru BK sedang menangani laporan ini.';
      case 'mediation': return 'Jadwal mediasi sedang disiapkan.';
      case 'completed': return 'Kasus telah selesai ditangani.';
      case 'rejected': return 'Laporan ditolak oleh Guru BK.';
      default: return 'Status sedang diperbarui.';
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
