import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/report_provider.dart';

class ReviewReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> reportData;

  const ReviewReportScreen({super.key, required this.reportData});

  @override
  ConsumerState<ReviewReportScreen> createState() => _ReviewReportScreenState();
}

class _ReviewReportScreenState extends ConsumerState<ReviewReportScreen> {
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);

    final data = {
      'title': widget.reportData['title'],
      'description': widget.reportData['description'],
      'category': widget.reportData['category'],
      'incident_location': widget.reportData['incidentLocation'],
      'incident_date': widget.reportData['incidentDate'],
      'is_anonymous': widget.reportData['isAnonymous'] == true ? 1 : 0,
    };

    final reportedName = widget.reportData['reportedId']?.toString() ?? '';
    if (reportedName.isNotEmpty) {
      data['participants'] = [
        {'role': 'terlapor', 'name': reportedName}
      ];
    }

    final filePaths = widget.reportData['filePaths'] as List<String>?;

    try {
      final created = await ref.read(createReportProvider.notifier).create(data, filePaths: filePaths);

      ref.invalidate(reportsProvider);

      if (mounted) {
        final code = created?.reportCode ?? 'REP-BARU';
        context.go('/report/success', extra: code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim laporan: $e'),
            backgroundColor: AppTheme.danger600,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Laporan', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pastikan data laporan Anda sudah benar sebelum dikirim.', style: TextStyle(color: AppTheme.neutral700)),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neutral300),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem('Judul Laporan', widget.reportData['title'] ?? '-'),
                  _buildReviewItem('Jenis Perundungan', widget.reportData['category'] ?? '-'),
                  _buildReviewItem('Tanggal Kejadian', widget.reportData['incidentDate'] ?? '-'),
                  _buildReviewItem('Lokasi Kejadian', widget.reportData['incidentLocation'] ?? '-'),
                  _buildReviewItem('Terlapor', widget.reportData['reportedId']?.toString().isEmpty ?? true ? '-' : widget.reportData['reportedId']),
                  _buildReviewItem('Kronologi', widget.reportData['description'] ?? '-'),
                  _buildReviewItem('Lampiran Bukti', widget.reportData['hasFile'] == true ? '${(widget.reportData['filePaths'] as List?)?.length ?? 0} File Terlampir' : 'Tidak ada lampiran'),
                  _buildReviewItem('Status Anonim', widget.reportData['isAnonymous'] == true ? 'Ya, disembunyikan' : 'Tidak (Tampil Publik)'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Kirim Laporan Sekarang'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                child: const Text('Kembali & Edit', style: TextStyle(color: AppTheme.neutral500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.neutral500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.neutral900)),
        ],
      ),
    );
  }
}
