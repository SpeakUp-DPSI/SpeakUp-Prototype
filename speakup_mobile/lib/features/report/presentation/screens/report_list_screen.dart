import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/report_model.dart';
import '../providers/report_provider.dart';
import '../widgets/report_search_delegate.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _selectedStatus = '';
  String _selectedSort = '';

  final List<Map<String, String>> _statusFilters = [
    {'value': '', 'label': 'Semua'},
    {'value': 'waiting_validation', 'label': 'Menunggu Validasi'},
    {'value': 'processing', 'label': 'Diproses'},
    {'value': 'mediation', 'label': 'Mediasi'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'rejected', 'label': 'Ditolak'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Laporan', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.neutral700),
            onPressed: () {
              showSearch(context: context, delegate: ReportSearchDelegate(ref));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: _statusFilters.map((f) => DropdownMenuItem(
                      value: f['value'],
                      child: Text(f['label']!, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _selectedStatus = val ?? '');
                      ref.invalidate(reportsProvider);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Terbaru', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'oldest', child: Text('Terlama', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'status', child: Text('Status', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedSort = val ?? '');
                    ref.invalidate(reportsProvider);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildReportList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    return Consumer(
      builder: (context, ref, _) {
        final reportsAsync = ref.watch(reportsProvider);

        return reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => EmptyStateWidget(
            icon: Icons.cloud_off,
            title: 'Gagal memuat laporan',
            subtitle: 'Periksa koneksi internet Anda dan tarik ke bawah untuk mencoba lagi.',
            iconColor: AppTheme.danger600,
          ),
          data: (reports) {
            var filteredReports = reports;
            if (_selectedStatus.isNotEmpty) {
              filteredReports = reports.where((r) => r.status == _selectedStatus).toList();
            }

            if (filteredReports.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: 'Belum ada laporan',
                subtitle: 'Mulai laporkan kasus perundungan untuk membantu menciptakan lingkungan sekolah yang aman.',
                actionLabel: 'Buat Laporan',
                onAction: () => context.push('/report/create'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(reportsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return _buildReportCard(report, context);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report, BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/report/${report.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description, color: AppTheme.primary600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.reportCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutral500)),
                    const SizedBox(height: 2),
                    Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (report.incidentLocation != null) ...[
                      const SizedBox(height: 4),
                      Text(report.incidentLocation!, style: const TextStyle(color: AppTheme.neutral500, fontSize: 12)),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(_formatStatus(report.status), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
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
