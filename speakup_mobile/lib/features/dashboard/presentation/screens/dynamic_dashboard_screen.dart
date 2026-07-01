import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'principal_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class DynamicDashboardScreen extends ConsumerWidget {
  const DynamicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthSuccess) {
      final role = authState.user.roles.isNotEmpty ? authState.user.roles.first : 'siswa';
      
      switch (role) {
        case 'guru_bk':
          return const TeacherDashboardScreen();
        case 'kepsek':
          return const PrincipalDashboardScreen();
        case 'ortu':
          return const ParentDashboardScreen();
        case 'admin':
          return const AdminDashboardScreen();
        case 'siswa':
        default:
          return const StudentDashboardScreen();
      }
    }

    return const Center(child: CircularProgressIndicator());
  }
}
