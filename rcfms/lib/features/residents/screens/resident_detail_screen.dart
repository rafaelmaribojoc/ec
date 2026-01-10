import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/repositories/resident_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../forms/templates/form_templates.dart';

class ResidentDetailScreen extends StatefulWidget {
  final String residentId;

  const ResidentDetailScreen({
    super.key,
    required this.residentId,
  });

  @override
  State<ResidentDetailScreen> createState() => _ResidentDetailScreenState();
}

class _ResidentDetailScreenState extends State<ResidentDetailScreen> {
  ResidentModel? _resident;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResident();
  }

  Future<void> _loadResident() async {
    try {
      final repository = context.read<ResidentRepository>();
      final resident = await repository.getResidentById(widget.residentId);
      setState(() {
        _resident = resident;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _resident == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Resident'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load resident: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final resident = _resident!;
    final authState = context.watch<AuthBloc>().state;
    final userUnit = authState is AuthAuthenticated ? authState.user.unit : null;

    // Get screen dimensions for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;
    final headerHeight = isSmallScreen ? 200.0 : 260.0;
    final avatarRadius = isSmallScreen ? 36.0 : 50.0;
    final nameFontSize = isSmallScreen ? 18.0 : 24.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: headerHeight,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Photo
                        Hero(
                          tag: 'resident-${resident.id}',
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.white,
                            backgroundImage: resident.photoUrl != null
                                ? CachedNetworkImageProvider(resident.photoUrl!)
                                : null,
                            child: resident.photoUrl == null
                                ? Text(
                                    resident.firstName[0] + resident.lastName[0],
                                    style: TextStyle(
                                      fontSize: avatarRadius * 0.64,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 16),
                        // Name
                        Text(
                          resident.fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        // Location
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 16,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  resident.displayLocation,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.timeline, color: Colors.white),
                onPressed: () => context.push(
                  '/residents/${resident.id}/timeline',
                ),
                tooltip: 'View Timeline',
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Actions
                _buildQuickActions(context, resident, userUnit),
                const SizedBox(height: 24),

                // Basic Info
                _buildSectionCard(
                  context,
                  title: 'Basic Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Date of Birth',
                        DateFormat('MMMM d, yyyy').format(resident.dateOfBirth)),
                    _buildInfoRow('Age', '${resident.age} years old'),
                    _buildInfoRow('Gender', resident.gender.toUpperCase()),
                    _buildInfoRow('Admission Date',
                        DateFormat('MMMM d, yyyy').format(resident.admissionDate)),
                  ],
                ),
                const SizedBox(height: 16),

                // Emergency Contact
                if (resident.emergencyContactName != null)
                  Column(
                    children: [
                      _buildSectionCard(
                        context,
                        title: 'Emergency Contact',
                        icon: Icons.emergency,
                        children: [
                          _buildInfoRow('Name', resident.emergencyContactName!),
                          if (resident.emergencyContactPhone != null)
                            _buildInfoRow('Phone', resident.emergencyContactPhone!),
                          if (resident.emergencyContactRelation != null)
                            _buildInfoRow('Relationship',
                                resident.emergencyContactRelation!),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Medical Info
                _buildSectionCard(
                  context,
                  title: 'Medical Information',
                  icon: Icons.medical_information,
                  children: [
                    if (resident.primaryDiagnosis != null)
                      _buildInfoRow('Primary Diagnosis', resident.primaryDiagnosis!),
                    if (resident.allergies != null)
                      _buildInfoRow('Allergies', resident.allergies!),
                    if (resident.medicalNotes != null)
                      _buildInfoRow('Notes', resident.medicalNotes!),
                    if (resident.primaryDiagnosis == null &&
                        resident.allergies == null &&
                        resident.medicalNotes == null)
                      const Text(
                        'No medical information recorded',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 80), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/residents/${resident.id}/timeline'),
        icon: const Icon(Icons.timeline),
        label: const Text('View Timeline'),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ResidentModel resident,
    String? userUnit,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing = screenWidth < 360 ? 8.0 : 12.0;

    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.description,
            label: 'New Form',
            color: AppColors.primary,
            compact: screenWidth < 360,
            onTap: () => _showFormSelector(context, resident, userUnit),
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history,
            label: 'History',
            color: AppColors.secondary,
            compact: screenWidth < 360,
            onTap: () => context.push('/residents/${resident.id}/timeline'),
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Export',
            color: AppColors.accent,
            compact: screenWidth < 360,
            onTap: () {
              // TODO: Export PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFormSelector(
    BuildContext context,
    ResidentModel resident,
    String? userUnit,
  ) {
    if (userUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be assigned to a unit to create forms'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final formTypes = AppConstants.formTypesByUnit[userUnit] ?? [];

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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Form Type',
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
                          context.push(
                            '/forms/fill/$templateId?residentId=${resident.id}&residentName=${Uri.encodeComponent(resident.fullName)}',
                          );
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

  String _getFormDisplayName(String templateId) {
    final template = FormTemplatesRegistry.getById(templateId);
    if (template != null) {
      return template.name;
    }
    // Fallback: format the ID nicely
    return templateId
        .replaceAll('ss_', '')
        .replaceAll('hl_', '')
        .replaceAll('ps_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use column layout for very small screens
          if (constraints.maxWidth < 280) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            );
          }
          // Use row layout for larger screens
          final labelWidth = constraints.maxWidth < 350 ? 100.0 : 120.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(compact ? 8 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: compact ? 20 : 24),
              SizedBox(height: compact ? 2 : 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form type card matching the Create New Form modal style
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to create',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color, String) _getFormTypeInfo(String templateId) {
    final template = FormTemplatesRegistry.getById(templateId);
    if (template != null) {
      return (template.icon, AppColors.getServiceUnitColor(template.serviceUnit.name), template.name);
    }

    // Fallback with smart defaults based on template ID prefix
    if (templateId.startsWith('ss_')) {
      return (Icons.social_distance, AppColors.unitSocial, _formatTemplateId(templateId));
    } else if (templateId.startsWith('hl_')) {
      return (Icons.home, AppColors.unitHomelife, _formatTemplateId(templateId));
    } else if (templateId.startsWith('ps_')) {
      return (Icons.psychology, AppColors.unitPsych, _formatTemplateId(templateId));
    } else if (templateId.startsWith('med_')) {
      return (Icons.medical_services, AppColors.unitMedical, _formatTemplateId(templateId));
    } else if (templateId.startsWith('rehab_')) {
      return (Icons.accessibility_new, AppColors.unitRehab, _formatTemplateId(templateId));
    }

    return (Icons.description, AppColors.primary, _formatTemplateId(templateId));
  }

  String _formatTemplateId(String templateId) {
    return templateId
        .replaceAll(RegExp(r'^(ss_|hl_|ps_|med_|rehab_)'), '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }
}
