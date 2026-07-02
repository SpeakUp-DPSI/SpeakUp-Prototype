import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/main_wrapper_screen.dart';
import '../../features/dashboard/presentation/screens/dynamic_dashboard_screen.dart';
import '../../features/report/presentation/screens/create_report_screen.dart';
import '../../features/report/presentation/screens/report_detail_screen.dart';
import '../../features/report/presentation/screens/review_report_screen.dart';
import '../../features/report/presentation/screens/report_success_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/mediation/presentation/screens/mediation_screen.dart';
import '../../features/followup/presentation/screens/follow_up_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/report/presentation/screens/report_list_screen.dart';
import '../../features/dashboard/presentation/screens/admin_audit_log_screen.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState is AuthSuccess;
      
      final path = state.uri.toString();
      final isGoingToAuth = path == '/' || path == '/onboarding' || path == '/login' || path == '/register';
      
      if (!isAuth && !isGoingToAuth) {
        return '/login';
      }
      
      if (isAuth && isGoingToAuth) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapperScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DynamicDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dummy-lapor',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportListScreen(),
    ),
    GoRoute(
      path: '/report/create',
      builder: (context, state) => const CreateReportScreen(),
    ),
    GoRoute(
      path: '/report/review',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ReviewReportScreen(reportData: extra);
      },
    ),
    GoRoute(
      path: '/report/success',
      builder: (context, state) {
        final code = state.extra as String? ?? 'SPK-ERROR';
        return ReportSuccessScreen(reportCode: code);
      },
    ),
    GoRoute(
      path: '/report/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return ReportDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/mediation/:id',
      builder: (context, state) => const MediationScreen(),
    ),
    GoRoute(
      path: '/followup/:id',
      builder: (context, state) => const FollowUpScreen(),
    ),
    GoRoute(
      path: '/audit-logs',
      builder: (context, state) => const AdminAuditLogScreen(),
    ),
  ],
  );
});
