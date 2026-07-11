import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: isDesktop ? null : AppBar(
        title: const Text('Admin Console', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        child: isDesktop
            ? _buildDesktopContent(context)
            : _buildMobileContent(context),
      ),
    );
  }

  // ─── Desktop Content ─────────────────────────────────────────────────
  Widget _buildDesktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ──────
        const Text(
          'Admin Console',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.neutral900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola sistem, pengguna, dan pantau aktivitas platform SpeakUp.',
          style: TextStyle(fontSize: 14, color: AppTheme.neutral500),
        ),
        const SizedBox(height: 28),

        // ─── Two-column: Menu Grid + System Status ──────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main — Menu Grid (2x2)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manajemen Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.2,
                    children: [
                      _buildDesktopMenuCard('Laporan', 'Kelola semua laporan bullying', Icons.description, AppTheme.primary600, () => context.go('/reports')),
                      _buildDesktopMenuCard('Notifikasi', 'Pengaturan notifikasi sistem', Icons.notifications, AppTheme.warning600, () => context.go('/notifications')),
                      _buildDesktopMenuCard('Audit Logs', 'Riwayat aktivitas pengguna', Icons.receipt_long, AppTheme.info600, () => context.push('/audit-logs')),
                      _buildDesktopMenuCard('Pengguna', 'Kelola akun siswa, guru, orang tua', Icons.manage_accounts_rounded, AppTheme.purple600, () => context.push('/admin/users')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Sidebar — System Status + Quick Stats
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // System Status
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
                        const Text('Status Sistem', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.success100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.success600.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_done, color: AppTheme.success600, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Semua Sistem Operasional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.success600)),
                                    const SizedBox(height: 2),
                                    Text('API v1.0.0 — Uptime 99.9%', style: TextStyle(fontSize: 11, color: AppTheme.neutral600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _statusRow(Icons.storage, 'Database', 'Operasional', AppTheme.success600),
                        const SizedBox(height: 10),
                        _statusRow(Icons.cloud_outlined, 'API Server', 'Operasional', AppTheme.success600),
                        const SizedBox(height: 10),
                        _statusRow(Icons.notifications_active, 'Push Notif', 'Aktif', AppTheme.success600),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick Stats
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
                        const Text('Statistik Cepat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
                        const SizedBox(height: 16),
                        _quickStatRow(Icons.people, 'Total Pengguna', '124'),
                        const SizedBox(height: 12),
                        _quickStatRow(Icons.description, 'Total Laporan', '47'),
                        const SizedBox(height: 12),
                        _quickStatRow(Icons.trending_up, 'Laporan Bulan Ini', '12'),
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

  Widget _statusRow(IconData icon, String label, String status, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.neutral500),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.neutral700))),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _quickStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: AppTheme.primary600),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.neutral700))),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
      ],
    );
  }

  Widget _buildDesktopMenuCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.neutral900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.neutral500), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.neutral400),
          ],
        ),
      ),
    );
  }

  // ─── Mobile Content ──────────────────────────────────────────────────
  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manajemen Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildMenuCard('Laporan', Icons.description, AppTheme.primary600, () => context.go('/reports')),
            _buildMenuCard('Notifikasi', Icons.notifications, AppTheme.warning600, () => context.go('/notifications')),
            _buildMenuCard('Audit Logs', Icons.receipt_long, AppTheme.info600, () => context.push('/audit-logs')),
            _buildMenuCard('Pengguna', Icons.manage_accounts_rounded, AppTheme.purple600, () => context.push('/admin/users')),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Status Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutral900)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.success100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success600.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_done, color: AppTheme.success600, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Semua sistem operasional', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success600)),
                  Text('Terhubung dengan API (v1.0.0)', style: TextStyle(fontSize: 12, color: AppTheme.neutral700)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
