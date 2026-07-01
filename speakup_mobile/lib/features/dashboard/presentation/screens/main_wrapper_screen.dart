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
      isStudent = authState.user.roles.contains('siswa');
    }

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: isStudent ? FloatingActionButton(
        onPressed: () {
          context.push('/report/create');
        },
        backgroundColor: AppTheme.primary600,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            if (index == 2) {
              if (isStudent) {
                context.push('/report/create');
              } else {
                context.push('/reports');
              }
              return; // Jangan goBranch untuk index 2, langsung push rute baru
            }
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary600,
          unselectedItemColor: AppTheme.neutral500,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            if (isStudent)
              const BottomNavigationBarItem(
                icon: Icon(Icons.add, color: Colors.transparent),
                label: 'Lapor',
              )
            else
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_customize),
                label: 'Kelola',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
