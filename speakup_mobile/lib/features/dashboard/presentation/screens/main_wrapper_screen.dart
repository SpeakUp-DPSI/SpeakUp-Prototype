import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class MainWrapperScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    bool isStudent = true;
    if (authState is AuthSuccess) {
      final role = authState.user.roles.isNotEmpty
          ? authState.user.roles.first.toLowerCase()
          : 'siswa';
      isStudent = role.contains('siswa') || authState.user.roles.isEmpty;
    }

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: isStudent
          ? Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primary600,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary600.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/report/create'),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          notchMargin: isStudent ? 8 : 0,
          shape: isStudent ? const CircularNotchedRectangle() : null,
          child: SizedBox(
            height: 60,
            child: isStudent
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
                      _navItem(1, Icons.history_outlined, Icons.history_rounded, 'Riwayat'),
                      const SizedBox(width: 60), // FAB placeholder
                      _navItem(3, Icons.list_alt_outlined, Icons.list_alt_rounded, 'Status'),
                      _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
                      _navItem(1, Icons.article_outlined, Icons.article_rounded, 'Laporan'),
                      _navItem(2, Icons.group_outlined, Icons.group_rounded, 'Mediasi'),
                      _navItem(3, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Rekap'),
                      _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = widget.navigationShell.currentIndex == index;
    final branchIndex = index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.navigationShell.goBranch(
            branchIndex,
            initialLocation:
                branchIndex == widget.navigationShell.currentIndex,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primary600 : AppTheme.neutral400,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                color:
                    isActive ? AppTheme.primary600 : AppTheme.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
