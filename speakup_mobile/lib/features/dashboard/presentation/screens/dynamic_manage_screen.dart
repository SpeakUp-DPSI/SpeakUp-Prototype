import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'admin_user_management_screen.dart';
import 'principal_monitoring_screen.dart';
import '../../../mediation/presentation/screens/mediation_screen.dart';

class DynamicManageScreen extends ConsumerWidget {
  const DynamicManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthSuccess) {
      final role = authState.user.roles.isNotEmpty ? authState.user.roles.first.toLowerCase() : 'siswa';
      
      if (role.contains('admin')) {
        return const AdminUserManagementScreen();
      } else if (role.contains('kepala') || role.contains('kepsek')) {
        return const PrincipalMonitoringScreen();
      } else if (role.contains('guru') || role.contains('bk')) {
        return const MediationScreen();
      } else {
        return const Center(child: Text('Tidak ada akses kelola'));
      }
    }

    return const Center(child: CircularProgressIndicator());
  }
}
