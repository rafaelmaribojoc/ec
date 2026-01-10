import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: 280,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Photo
                      Hero(
                        tag: 'resident-${resident.id}',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: resident.photoUrl != null
                              ? CachedNetworkImageProvider(resident.photoUrl!)
                              : null,
                          child: resident.photoUrl == null
                              ? Text(
                                  resident.firstName[0] + resident.lastName[0],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        resident.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              resident.displayLocation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.description,
            label: 'New Form',
            color: AppColors.primary,
            onTap: () => _showFormSelector(context, resident, userUnit),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history,
            label: 'History',
            color: AppColors.secondary,
            onTap: () => context.push('/residents/${resident.id}/timeline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Export',
            color: AppColors.accent,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Form Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...formTypes.map((type) => ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(_getFormDisplayName(type)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push(
                        '/forms/fill/$type?residentId=${resident.id}',
                      );
                    },
                  )),
            ],
          ),
        );
      },
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
