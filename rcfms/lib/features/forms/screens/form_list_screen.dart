import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../../../data/models/form_submission_model.dart';
import '../../../data/repositories/form_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../templates/form_templates.dart';

class FormListScreen extends StatefulWidget {
  const FormListScreen({super.key});

  @override
  State<FormListScreen> createState() => _FormListScreenState();
}

class _FormListScreenState extends State<FormListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FormRepository _formRepo = FormRepository();

  List<FormSubmissionModel> _forms = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _tabs = ['All', 'Draft', 'Submitted', 'Approved'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadForms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadForms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final forms = await _formRepo.getForms();
      setState(() {
        _forms = forms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<FormSubmissionModel> _getFilteredForms(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return _forms.where((f) => f.status == 'draft').toList();
      case 2:
        return _forms.where((f) => f.status == 'submitted').toList();
      case 3:
        return _forms.where((f) => f.status == 'approved').toList();
      default:
        return _forms;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Forms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Form',
            onPressed: _showNewFormSheet,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (index) {
          return _buildFormList(index);
        }),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
      floatingActionButton: const MainScanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFormList(int tabIndex) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final forms = _getFilteredForms(tabIndex);

    if (forms.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return RefreshIndicator(
      onRefresh: _loadForms,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: forms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final form = forms[index];
          return _FormCard(
            form: form,
            onTap: () {
              if (form.status == 'draft') {
                context.push('/forms/fill/${form.templateId}?formId=${form.id}');
              } else {
                context.push('/forms/${form.id}');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final message = tabIndex == 1
        ? 'No draft forms'
        : tabIndex == 2
            ? 'No submitted forms'
            : tabIndex == 3
                ? 'No approved forms'
                : 'No forms yet';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new form to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load forms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadForms,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewFormSheet() {
    final authState = context.read<AuthBloc>().state;
    String? userUnit;
    if (authState is AuthAuthenticated) {
      userUnit = authState.user.unit;
    }

    final formTypes = AppConstants.formTypesByUnit[userUnit] ??
        AppConstants.formTypesByUnit['social']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! > 10) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Form',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formTypes.length} templates available',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Template list
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: formTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final templateId = formTypes[index];
                      return _FormTypeCard(
                        templateId: templateId,
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/forms/fill/$templateId');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Utility to format template type names for display
String _formatTemplateName(String templateType) {
  // Map of template types to user-friendly names
  const templateNames = {
    'pre_admission_checklist': 'Pre-Admission Checklist',
    'requirements_checklist': 'Requirements Checklist',
    'general_intake_sheet': 'General Intake Sheet',
    'admission_case_conference': 'Admission Case Conference',
    'clients_contract': "Client's Contract",
    'admission_slip': 'Admission Slip',
    'progress_notes': 'Progress Notes',
    'running_notes': 'Running Notes',
    'intervention_plan': 'Intervention Plan',
    'social_case_study': 'Social Case Study',
    'case_conference': 'Case Conference',
    'termination_report': 'Termination Report',
    'closing_summary': 'Closing Summary',
    'quarterly_narrative': 'Quarterly Narrative Report',
    'inventory_admission': 'Inventory Upon Admission',
    'inventory_discharge': 'Inventory Upon Discharge',
    'inventory_monthly': 'Monthly Inventory Report',
    'incident_report': 'Incident Report',
    'out_on_pass': 'Out on Pass',
    'group_sessions': 'Group Sessions Report',
    'individual_sessions': 'Individual Sessions Report',
    'inter_service_referral': 'Inter-Service Referral',
    'initial_assessment': 'Initial Assessment',
    'psychometrician_report': "Psychometrician's Report",
    'daily_vitals': 'Daily Vitals',
    'medical_abstract': 'Medical Abstract',
    'moca_p_scoring': 'MOCA-P Scoring',
    'behavior_log': 'Behavior Log',
    'therapy_session_notes': 'Therapy Session Notes',
    'daily_activity_log': 'Daily Activity Log',
  };

  // Return mapped name or format the raw template type
  if (templateNames.containsKey(templateType)) {
    return templateNames[templateType]!;
  }

  // Fallback: Convert snake_case to Title Case
  return templateType
      .split('_')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1)}'
          : '')
      .join(' ');
}

class _FormCard extends StatelessWidget {
  final FormSubmissionModel form;
  final VoidCallback onTap;

  const _FormCard({
    required this.form,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(form.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: _getStatusColor(form.status),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTemplateName(form.templateType),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Resident: ${form.residentId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, y').format(form.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status
              _StatusBadge(status: form.status),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraft;
      case 'submitted':
        return AppColors.statusSubmitted;
      case 'pending_review':
        return AppColors.statusPendingReview;
      case 'approved':
        return AppColors.statusApproved;
      case 'returned':
        return AppColors.statusReturned;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = _getStatusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (Color, Color, String) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return (
          AppColors.statusDraft,
          AppColors.surfaceHover,
          'Draft',
        );
      case 'submitted':
        return (
          AppColors.statusSubmitted,
          AppColors.infoSurface,
          'Submitted',
        );
      case 'pending_review':
        return (
          AppColors.statusPendingReview,
          AppColors.warningSurface,
          'Pending',
        );
      case 'approved':
        return (
          AppColors.statusApproved,
          AppColors.successSurface,
          'Approved',
        );
      case 'returned':
        return (
          AppColors.statusReturned,
          AppColors.errorSurface,
          'Returned',
        );
      default:
        return (
          AppColors.textSecondary,
          AppColors.surfaceHover,
          status,
        );
    }
  }
}

class _FormTypeCard extends StatelessWidget {
  final String templateId;
  final VoidCallback onTap;

  const _FormTypeCard({
    required this.templateId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, displayName) = _getFormTypeInfo(templateId);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to create',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color, String) _getFormTypeInfo(String templateId) {
    // First try to get from FormTemplatesRegistry for accurate info
    final template = FormTemplatesRegistry.getById(templateId);
    if (template != null) {
      return (
        template.icon,
        AppColors.getServiceUnitColor(template.serviceUnit.name),
        template.name,
      );
    }

    // Fallback with smart defaults based on template ID prefix
    Color color;
    IconData icon;
    
    if (templateId.startsWith('ss_')) {
      color = AppColors.unitSocial;
      icon = Icons.people;
    } else if (templateId.startsWith('hl_')) {
      color = AppColors.unitHomelife;
      icon = Icons.home;
    } else if (templateId.startsWith('ps_')) {
      color = AppColors.unitPsych;
      icon = Icons.psychology;
    } else if (templateId.startsWith('med_')) {
      color = AppColors.unitMedical;
      icon = Icons.medical_services;
    } else if (templateId.startsWith('rehab_')) {
      color = AppColors.unitRehab;
      icon = Icons.accessibility_new;
    } else {
      color = AppColors.primary;
      icon = Icons.description;
    }

    // Format the name nicely - remove prefix and convert to title case
    final displayName = _formatTemplateIdToName(templateId);
    return (icon, color, displayName);
  }

  /// Formats template ID to a clean display name
  String _formatTemplateIdToName(String templateId) {
    // Remove known prefixes
    String name = templateId
        .replaceFirst(RegExp(r'^(ss_|hl_|ps_|med_|rehab_)'), '');
    
    // Convert underscores to spaces and capitalize each word
    return name
        .split('_')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
