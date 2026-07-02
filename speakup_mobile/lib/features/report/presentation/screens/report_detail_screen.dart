import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/report_provider.dart';
import 'package:go_router/go_router.dart';

class ReportDetailScreen extends ConsumerWidget {
  final int id;

  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(id));
    final authState = ref.watch(authProvider);

    // Role check — robust dengan contains()
    final role = authState is AuthSuccess
        ? (authState.user.roles.isNotEmpty
            ? authState.user.roles.first.toLowerCase()
            : 'siswa')
        : 'siswa';
    final isTeacher = role.contains('guru');
    final isAdmin = role.contains('admin');
    final canValidate = isTeacher || isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.neutral700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Laporan',
          style: TextStyle(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.neutral700),
            onPressed: () {},
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
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
              subtitle: 'Laporan ini tidak tersedia atau telah dihapus.',
              iconColor: AppTheme.neutral400,
            );
          }

          final statusColor = _getBadgeColor(report.status);
          final statusLabel = _formatStatus(report.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header Card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primary50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.article_outlined,
                                color: AppTheme.primary600, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      report.reportCode,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.primary600),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (report.incidentDate != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 13,
                                          color: AppTheme.neutral400),
                                      const SizedBox(width: 4),
                                      Text(
                                        report.incidentDate!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.neutral400),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (report.category != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text(
                              'Jenis Perundungan',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.neutral500),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                report.category!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Data Kejadian ────────────────────────────────────────
                _sectionCard(
                  title: 'Data Kejadian',
                  icon: Icons.calendar_month_outlined,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _infoCol(
                                Icons.calendar_today_outlined,
                                'Tanggal Kejadian',
                                report.incidentDate ?? '-',
                              ),
                            ),
                            Expanded(
                              child: _infoCol(
                                Icons.access_time_outlined,
                                'Wktu Kejadian',
                                '10:00 WIB',
                              ),
                            ),
                            Expanded(
                              child: _infoCol(
                                null,
                                'Lokasi Kejadian',
                                report.incidentLocation ?? '-',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kronologi Kejadian',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.neutral900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.description.isNotEmpty
                              ? report.description
                              : 'Tidak ada kronologi tersedia.',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.neutral700,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Identitas Pelapor ────────────────────────────────────
                _personCard('Identitas Pelapor', 'Siswa', 'Kelas X-2',
                    report.isAnonymous),
                const SizedBox(height: 12),

                // ─── Data Korban ──────────────────────────────────────────
                _personCard('Data Korban', 'Siswa', 'Kelas X-2',
                    report.isAnonymous),
                const SizedBox(height: 12),

                // ─── Data Terlapor ────────────────────────────────────────
                _personCard('Data Terlapor', 'Siswa', 'Kelas X-2',
                    false),
                const SizedBox(height: 12),

                // ─── Data Saksi ───────────────────────────────────────────
                _personCard('Data Saksi (2)', 'Siswa', 'Kelas X-2',
                    false, showBadge: false),
                const SizedBox(height: 12),

                // ─── Aksi Validasi ────────────────────────────────────────
                if (canValidate && report.status == 'waiting_validation') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleStatusUpdate(
                              context, ref, report.id, 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger600,
                            side: const BorderSide(
                                color: AppTheme.danger600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleStatusUpdate(
                              context, ref, report.id, 'processing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: const Text('Validasi & Proses',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionCard(
      {required String title,
      required IconData icon,
      required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primary600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.neutral900),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _personCard(String title, String role, String kelas,
      bool isAnonymous,
      {bool showBadge = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 18, color: AppTheme.primary600),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.neutral900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(Icons.person,
                    color: AppTheme.neutral400, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Andi Pratama',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.neutral900),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.neutral400),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kelas,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.neutral600),
                ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAnonymous
                        ? 'Identitas Dirahasiakan'
                        : 'Identitas Terbuka',
                    style: const TextStyle(
                        fontSize: 9, color: AppTheme.neutral600),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCol(IconData? icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppTheme.neutral400),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.neutral400),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral900),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, WidgetRef ref,
      int reportId, String newStatus) async {
    try {
      final dataSource = ref.read(reportRemoteDataSourceProvider);
      await dataSource.updateStatus(reportId, newStatus);
      ref.invalidate(reportDetailProvider(reportId));
      ref.invalidate(reportsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Status berhasil diubah menjadi ${_formatStatus(newStatus)}'),
          backgroundColor: newStatus == 'rejected'
              ? AppTheme.danger600
              : AppTheme.success600,
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

  Color _getBadgeColor(String status) {
    switch (status) {
      case 'waiting_validation':
        return AppTheme.warning600;
      case 'processing':
        return AppTheme.primary600;
      case 'mediation':
        return const Color(0xFF7C3AED);
      case 'completed':
        return AppTheme.success600;
      case 'rejected':
        return AppTheme.danger600;
      default:
        return AppTheme.neutral500;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu Validasi';
      case 'processing':
        return 'Diproses';
      case 'mediation':
        return 'Mediasi';
      case 'follow_up':
        return 'Tindak Lanjut';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Terkirim';
    }
  }
}
