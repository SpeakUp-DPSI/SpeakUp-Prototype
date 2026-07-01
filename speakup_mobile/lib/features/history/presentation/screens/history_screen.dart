import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../report/presentation/providers/report_provider.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => EmptyStateWidget(
          icon: Icons.cloud_off,
          title: 'Gagal memuat riwayat',
          subtitle: 'Tarik ke bawah untuk mencoba lagi.',
          iconColor: AppTheme.danger600,
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history,
              title: 'Belum ada riwayat',
              subtitle: 'Laporan yang Anda buat akan muncul di sini.',
              actionLabel: 'Buat Laporan',
              onAction: () => context.push('/report/create'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(reportsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final statusColor = _getStatusColor(report.status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutral300),
                  ),
                  child: ListTile(
                    onTap: () => context.push('/report/${report.id}'),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.assignment, color: statusColor),
                    ),
                    title: Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.neutral700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(_formatStatus(report.status), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.neutral400),
                  ),
                );
              },
            ),
          );
        },
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
