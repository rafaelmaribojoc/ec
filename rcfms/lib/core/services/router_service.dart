import 'package:flutter/foundation.dart';
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
import '../../data/repositories/resident_repository.dart';
import '../../data/repositories/form_repository.dart';

// MoCA-P Assessment imports
import '../../features/moca/screens/visuospatial_screen.dart';
import '../../features/moca/screens/naming_screen.dart';
import '../../features/moca/screens/memory_screen.dart';
import '../../features/moca/screens/attention_screen.dart';
import '../../features/moca/screens/language_screen.dart';
import '../../features/moca/screens/abstraction_screen.dart';
import '../../features/moca/screens/delayed_recall_screen.dart';
import '../../features/moca/screens/orientation_screen.dart';
import '../../features/moca/screens/assessment_complete_screen.dart';

void _log(String message) {
  if (kDebugMode) {
    print('[Router] $message');
  }
}

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

      _log(
          'Redirect check - location: ${state.matchedLocation}, isLoggedIn: $isLoggedIn, authState: ${authState.runtimeType}');

      // Handle loading state - allow current location
      if (authState is AuthLoading) {
        _log('Auth loading, allowing current location');
        return null;
      }

      // If not logged in (including after logout), redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        _log('Not logged in, redirecting to /login');
        return '/login';
      }

      // If logged in but on login page, redirect to dashboard
      // Note: Signature setup is now optional and done in Settings
      if (isLoggedIn && isLoggingIn) {
        _log('Logged in at login page, redirecting to /dashboard');
        return '/dashboard';
      }

      // If logged in and setting up signature, allow it
      if (isLoggedIn && isSettingUpSignature) {
        _log('Allowing signature setup');
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
                builder: (context, state) {
                  final viewMode = state.uri.queryParameters['mode'] == 'view';
                  return ResidentDetailScreen(
                    residentId: state.pathParameters['id']!,
                    isViewMode: viewMode,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'timeline',
                    name: 'resident-timeline',
                    parentNavigatorKey: _rootNavigatorKey,
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
                  final residentId =
                      state.uri.queryParameters['residentId'] ?? '';
                  final residentName =
                      state.uri.queryParameters['residentName'] ??
                          'Unknown Resident';
                  final unit = state.uri.queryParameters['unit'];
                  final formId = state.uri.queryParameters['formId'];

                  // Try to find template by ID first, then by templateType
                  FormTemplate? template =
                      FormTemplatesRegistry.getById(templateId);
                  if (template == null && unit != null) {
                    template = FormTemplatesRegistry.getByTypeAndUnit(
                        templateId, unit);
                  }
                  template ??= FormTemplatesRegistry.getByType(templateId);

                  if (template == null) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
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

                  // If formId is provided, this is an edit of existing form (e.g., returned form)
                  if (formId != null && formId.isNotEmpty) {
                    return _FormEditScreen(
                      templateId: templateId,
                      formId: formId,
                    );
                  }

                  // If residentId is provided, fetch resident data for smart defaults
                  if (residentId.isNotEmpty) {
                    return _FormFillScreenWithResidentData(
                      template: template,
                      residentId: residentId,
                      residentName: residentName,
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

          // MoCA-P Assessment routes - accessed only via resident selection (NFC or Browse)
        ],
      ),

      // MoCA-P Assessment routes (flat structure to avoid navigator key conflicts)
      // /moca redirects to dashboard - assessments must start from a resident
      GoRoute(
        path: '/moca',
        name: 'moca',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/moca/visuospatial',
        name: 'moca-visuospatial',
        builder: (context, state) => const VisuospatialScreen(),
      ),
      GoRoute(
        path: '/moca/naming',
        name: 'moca-naming',
        builder: (context, state) => const NamingScreen(),
      ),
      GoRoute(
        path: '/moca/memory',
        name: 'moca-memory',
        builder: (context, state) => const MemoryScreen(),
      ),
      GoRoute(
        path: '/moca/attention',
        name: 'moca-attention',
        builder: (context, state) => const AttentionScreen(),
      ),
      GoRoute(
        path: '/moca/language',
        name: 'moca-language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/moca/abstraction',
        name: 'moca-abstraction',
        builder: (context, state) => const AbstractionScreen(),
      ),
      GoRoute(
        path: '/moca/delayed-recall',
        name: 'moca-delayed-recall',
        builder: (context, state) => const DelayedRecallScreen(),
      ),
      GoRoute(
        path: '/moca/orientation',
        name: 'moca-orientation',
        builder: (context, state) => const OrientationScreen(),
      ),
      GoRoute(
        path: '/moca/complete',
        name: 'moca-complete',
        builder: (context, state) => const AssessmentCompleteScreen(),
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

/// Helper widget to fetch resident data and pass it to FormFillScreen
class _FormFillScreenWithResidentData extends StatefulWidget {
  final FormTemplate template;
  final String residentId;
  final String residentName;

  const _FormFillScreenWithResidentData({
    required this.template,
    required this.residentId,
    required this.residentName,
  });

  @override
  State<_FormFillScreenWithResidentData> createState() =>
      _FormFillScreenWithResidentDataState();
}

class _FormFillScreenWithResidentDataState
    extends State<_FormFillScreenWithResidentData> {
  Map<String, dynamic>? _residentData;
  bool _isLoading = true;
  // ignore: unused_field
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResidentData();
  }

  Future<void> _fetchResidentData() async {
    try {
      final residentRepo = context.read<ResidentRepository>();
      final resident = await residentRepo.getResidentById(widget.residentId);

      if (mounted) {
        setState(() {
          _residentData = {
            'full_name': resident.fullName,
            'fullName': resident.fullName,
            'resident_code': resident.residentCode,
            'residentCode': resident.residentCode,
            'age': resident.age,
            'gender': resident.gender,
            'date_of_birth': resident.dateOfBirth.toIso8601String(),
            'dateOfBirth': resident.dateOfBirth.toIso8601String(),
            'admission_date': resident.admissionDate.toIso8601String(),
            'admissionDate': resident.admissionDate.toIso8601String(),
            'ward_name': resident.currentWardId,
            'wardName': resident.currentWardId,
            'room_number': resident.roomNumber,
            'roomNumber': resident.roomNumber,
            'bed_number': resident.bedNumber,
            'bedNumber': resident.bedNumber,
            'primary_diagnosis': resident.primaryDiagnosis,
            'primaryDiagnosis': resident.primaryDiagnosis,
            'emergency_contact_name': resident.emergencyContactName,
            'emergencyContactName': resident.emergencyContactName,
            'emergency_contact_phone': resident.emergencyContactPhone,
            'emergencyContactPhone': resident.emergencyContactPhone,
            'emergency_contact_relation': resident.emergencyContactRelation,
            'emergencyContactRelation': resident.emergencyContactRelation,
          };
          _isLoading = false;
        });
      } else {
        // If resident not found, proceed without smart defaults
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _log('Error fetching resident data: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading resident data...'),
            ],
          ),
        ),
      );
    }

    return FormFillScreen(
      template: widget.template,
      residentId: widget.residentId,
      residentName: widget.residentName,
      residentData: _residentData,
    );
  }
}

/// Helper widget to fetch existing form data for editing (e.g., returned forms)
class _FormEditScreen extends StatefulWidget {
  final String templateId;
  final String formId;

  const _FormEditScreen({
    required this.templateId,
    required this.formId,
  });

  @override
  State<_FormEditScreen> createState() => _FormEditScreenState();
}

class _FormEditScreenState extends State<_FormEditScreen> {
  Map<String, dynamic>? _formData;
  String? _residentId;
  String? _residentName;
  FormTemplate? _template;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    try {
      final formRepo = context.read<FormRepository>();
      final form = await formRepo.getFormById(widget.formId);

      // Get the correct template based on form's unit
      FormTemplate? template = FormTemplatesRegistry.getByTypeAndUnit(
        form.templateType,
        form.unit,
      );
      template ??= FormTemplatesRegistry.getByType(form.templateType);

      if (mounted) {
        setState(() {
          _formData = form.formData;
          _residentId = form.residentId;
          _residentName = form.residentName ?? 'Unknown Resident';
          _template = template;
          _isLoading = false;
        });
      }
    } catch (e) {
      _log('Error fetching form data for edit: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Form...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading form data...'),
            ],
          ),
        ),
      );
    }

    if (_error != null || _template == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error != null
                  ? 'Failed to load form: $_error'
                  : 'Template not found'),
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
      template: _template!,
      residentId: _residentId ?? '',
      residentName: _residentName ?? 'Unknown Resident',
      initialData: _formData,
      existingSubmissionId: widget.formId,
      isEditing: true,
    );
  }
}
