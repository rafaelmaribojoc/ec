import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/setup_signature_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/residents/screens/residents_list_screen.dart';
import '../../features/residents/screens/resident_detail_screen.dart';
import '../../features/residents/screens/add_resident_screen.dart';
import '../../features/timeline/screens/timeline_screen.dart';
import '../../features/forms/screens/form_list_screen.dart';
import '../../features/forms/screens/form_fill_screen.dart';
import '../../features/forms/screens/form_view_screen.dart';
import '../../features/forms/templates/form_templates.dart';
import '../../features/approvals/screens/approvals_screen.dart';
import '../../features/nfc/screens/nfc_scan_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/ward_management_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../core/widgets/shell_scaffold.dart';

/// Application routing configuration
class RouterService {
  RouterService._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSettingUpSignature = state.matchedLocation == '/setup-signature';

      // If not logged in, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in but on login page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        // Check if user needs to set up signature
        if (authState.user.signatureUrl == null) {
          return '/setup-signature';
        }
        return '/dashboard';
      }

      // If logged in and setting up signature, allow it
      if (isLoggedIn && isSettingUpSignature) {
        return null;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setup-signature',
        name: 'setup-signature',
        builder: (context, state) => const SetupSignatureScreen(),
      ),

      // Main app shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const DashboardScreen(),
            ),
          ),

          // NFC Scan
          GoRoute(
            path: '/scan',
            name: 'scan',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const NFCScanScreen(),
            ),
          ),

          // Residents
          GoRoute(
            path: '/residents',
            name: 'residents',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ResidentsListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-resident',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddResidentScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'resident-detail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => ResidentDetailScreen(
                  residentId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'timeline',
                    name: 'resident-timeline',
                    builder: (context, state) => TimelineScreen(
                      residentId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Forms
          GoRoute(
            path: '/forms',
            name: 'forms',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const FormListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'fill/:templateId',
                name: 'form-fill',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final templateId = state.pathParameters['templateId']!;
                  final residentId = state.uri.queryParameters['residentId'] ?? '';
                  final residentName = state.uri.queryParameters['residentName'] ?? 'Unknown Resident';
                  final unit = state.uri.queryParameters['unit'];
                  
                  // Try to find template by ID first, then by templateType
                  FormTemplate? template = FormTemplatesRegistry.getById(templateId);
                  if (template == null && unit != null) {
                    template = FormTemplatesRegistry.getByTypeAndUnit(templateId, unit);
                  }
                  if (template == null) {
                    template = FormTemplatesRegistry.getByType(templateId);
                  }
                  
                  if (template == null) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Template "$templateId" not found'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => context.go('/forms'),
                              child: const Text('Go Back'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return FormFillScreen(
                    template: template,
                    residentId: residentId,
                    residentName: residentName,
                  );
                },
              ),
              GoRoute(
                path: 'view/:formId',
                name: 'form-view',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => FormViewScreen(
                  formId: state.pathParameters['formId']!,
                ),
              ),
            ],
          ),

          // Approvals (for unit heads)
          GoRoute(
            path: '/approvals',
            name: 'approvals',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ApprovalsScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),

          // Admin routes
          GoRoute(
            path: '/admin',
            name: 'admin',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const AdminDashboardScreen(),
            ),
            routes: [
              GoRoute(
                path: 'users',
                name: 'user-management',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const UserManagementScreen(),
              ),
              GoRoute(
                path: 'wards',
                name: 'ward-management',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const WardManagementScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
