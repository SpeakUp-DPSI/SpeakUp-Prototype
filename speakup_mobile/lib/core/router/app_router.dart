import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/main_wrapper_screen.dart';
import '../../features/dashboard/presentation/screens/dynamic_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/dynamic_list_screen.dart';
import '../../features/dashboard/presentation/screens/dynamic_manage_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/mediation/presentation/screens/mediation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/report/presentation/screens/create_report_screen.dart';
import '../../features/report/presentation/screens/report_detail_screen.dart';
import '../../features/report/presentation/screens/review_report_screen.dart';
import '../../features/report/presentation/screens/report_success_screen.dart';
import '../../features/mediation/presentation/screens/create_mediation_screen.dart';
import '../../features/mediation/presentation/screens/mediation_chat_screen.dart';
import '../../features/mediation/presentation/screens/mediation_detail_page.dart';
import '../../features/followup/presentation/screens/follow_up_screen.dart';
import '../../features/followup/presentation/screens/create_follow_up_screen.dart';
import '../../features/dashboard/presentation/screens/admin_audit_log_screen.dart';
import '../../features/dashboard/presentation/screens/principal_recap_screen.dart';
import '../../features/dashboard/presentation/screens/principal_monitoring_screen.dart';
import '../../features/dashboard/presentation/screens/admin_user_management_screen.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

import 'route_observer.dart';

/// Number of branches in the StatefulShellRoute.
/// All roles share these 5 branches; tabs are shown/hidden per role.
const int kShellBranchCount = 5;

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/',
    debugLogDiagnostics: false,
    observers: [AppRouteObserver.instance],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is AuthSuccess;

      final path = state.uri.toString();
      final isPublicPath = path == '/' ||
          path == '/onboarding' ||
          path == '/login' ||
          path == '/register' ||
          path == '/forgot-password' ||
          path == '/reset-password';

      // Unauthenticated users can only access public routes.
      if (!isAuthenticated && !isPublicPath) {
        return '/login';
      }

      // Authenticated users should not see public routes.
      if (isAuthenticated && isPublicPath) {
        return '/dashboard';
      }

      // ── Role-based access control ────────────────────────────────────────
      if (isAuthenticated) {
        final roles = authState.user.roles.map((r) => r.toLowerCase()).toList();

        // Admin-only routes.
        if ((path == '/audit-logs' || path == '/admin/users') &&
            !roles.contains('admin')) {
          return '/dashboard';
        }

        // Kepsek-only routes.
        if ((path == '/principal/recap' ||
                path == '/principal/monitoring') &&
            !roles.contains('kepsek') &&
            !roles.contains('admin')) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      // ─── Public routes ─────────────────────────────────────────────────────
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

      // ─── Shell route with bottom navigation (5 branches) ───────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 — Dashboard (all roles)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DynamicDashboardScreen(),
              ),
            ],
          ),

          // Branch 1 — List (History for student, ReportList for others)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const DynamicListScreen(),
              ),
            ],
          ),

          // Branch 2 — Manage (role-specific management screens)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manage',
                builder: (context, state) => const DynamicManageScreen(),
              ),
            ],
          ),

          // Branch 3 — Notifications / secondary (role-specific)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),

          // Branch 4 — Profile (all roles)
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

      // ─── Profile sub-routes (pushed on top of shell) ───────────────────────
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ─── Report routes (full-screen, pushed on top of shell) ───────────────
      GoRoute(
        path: '/report/create',
        pageBuilder: (context, state) {
          final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(TABLET);
          if (isDesktop) {
            return CustomTransitionPage(
              key: state.pageKey,
              opaque: false,
              barrierDismissible: true,
              barrierColor: Colors.black.withValues(alpha: 0.2),
              child: const CreateReportScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4 * animation.value, sigmaY: 4 * animation.value),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            );
          }
          return const MaterialPage(
            child: CreateReportScreen(),
          );
        },
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
        path: '/report/:id/create-mediation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CreateMediationScreen(
            reportId: extra['reportId'] ?? 0,
            reportCode: extra['reportCode'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/report/:id/create-follow-up',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CreateFollowUpScreen(
            reportId: extra['reportId'] ?? 0,
            reportCode: extra['reportCode'] ?? '',
          );
        },
      ),

      // ─── Mediation detail ──────────────────────────────────────────────────
      GoRoute(
        path: '/mediation/:id',
        builder: (context, state) => const MediationScreen(),
      ),

      // ─── Mediation detail ──────────────────────────────────────────────────
      GoRoute(
        path: '/mediation-detail',
        builder: (context, state) {
          final mediation = state.extra as dynamic;
          return MediationDetailPage(mediation: mediation);
        },
      ),

      // ─── Mediation chat ────────────────────────────────────────────────────
      GoRoute(
        path: '/mediation-chat',
        builder: (context, state) {
          final mediationId = state.extra as String? ?? '';
          return MediationChatScreen(mediationId: mediationId);
        },
      ),

      // ─── Follow-up detail ──────────────────────────────────────────────────
      GoRoute(
        path: '/followup/:id',
        builder: (context, state) => const FollowUpScreen(),
      ),

      // ─── Admin routes ──────────────────────────────────────────────────────
      GoRoute(
        path: '/audit-logs',
        builder: (context, state) => const AdminAuditLogScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementScreen(),
      ),

      // ─── Principal (Kepsek) routes ─────────────────────────────────────────
      GoRoute(
        path: '/principal/recap',
        builder: (context, state) => const PrincipalRecapScreen(),
      ),
      GoRoute(
        path: '/principal/monitoring',
        builder: (context, state) => const PrincipalMonitoringScreen(),
      ),
    ],
  );

  // Refresh router when auth state changes.
  ref.listen(authProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
