import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/models/form_submission_model.dart';
import '../../../data/repositories/resident_repository.dart';
import '../../../data/repositories/form_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../forms/templates/form_templates.dart';
import '../../moca/bloc/moca_assessment_bloc.dart';
import '../../moca/constants/moca_colors.dart';

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
                const SizedBox(height: 16),
                
                // Recent Forms Section
                _buildRecentFormsSection(context, resident),
                
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
    
    // Check if user can manage residents (transfer wards)
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final canManage = AppConstants.canManageResidents(user?.role, user?.unit);
    
    // Check if user is from psych unit (can do MoCA assessments)
    final isPsychUnit = userUnit == 'psych';

    return Column(
      children: [
        Row(
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
                icon: Icons.folder_open,
                label: 'Forms',
                color: AppColors.secondary,
                compact: screenWidth < 360,
                onTap: () => _showResidentForms(context, resident),
              ),
            ),
            SizedBox(width: buttonSpacing),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.picture_as_pdf,
                label: 'Export',
                color: AppColors.accent,
                compact: screenWidth < 360,
                onTap: () => _exportResidentProfile(context, resident),
              ),
            ),
          ],
        ),
        // Assessment button for psych unit
        if (isPsychUnit) ...[
          SizedBox(height: buttonSpacing),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.psychology,
                  label: 'New Assessment',
                  color: MocaColors.primary,
                  compact: screenWidth < 360,
                  onTap: () => _startMocaAssessment(context, resident),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.history,
                  label: 'Timeline',
                  color: AppColors.info,
                  compact: screenWidth < 360,
                  onTap: () => context.push('/residents/${resident.id}/timeline'),
                ),
              ),
            ],
          ),
        ],
        if (canManage) ...[
          SizedBox(height: buttonSpacing),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transfer Ward',
                  color: AppColors.warning,
                  compact: screenWidth < 360,
                  onTap: () => _showWardTransferDialog(context, resident),
                ),
              ),
              if (!isPsychUnit) ...[
                SizedBox(width: buttonSpacing),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history,
                    label: 'Timeline',
                    color: AppColors.info,
                    compact: screenWidth < 360,
                    onTap: () => context.push('/residents/${resident.id}/timeline'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
  
  /// Start MoCA-P assessment with auto-filled resident data
  void _startMocaAssessment(BuildContext context, ResidentModel resident) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    
    // Default education years to 0 (will trigger adjustment if < 12 years)
    // In real implementation, this would be fetched from resident data
    const educationYears = 0;
    
    // Start assessment with resident data auto-filled
    context.read<MocaAssessmentBloc>().add(
      MocaStartAssessment(
        residentId: resident.id,
        clinicianId: user?.id,
        residentName: resident.fullName,
        residentSex: resident.gender,
        residentBirthday: resident.dateOfBirth,
        educationYears: educationYears,
        educationAdjustment: educationYears < 12,
      ),
    );
    
    // Navigate to MoCA home screen with resident info
    context.push('/moca');
  }
  
  void _showResidentForms(BuildContext context, ResidentModel resident) {
    // Show a bottom sheet with all forms for this resident
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResidentFormsSheet(resident: resident),
    );
  }
  
  Future<void> _exportResidentProfile(BuildContext context, ResidentModel resident) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF export...')),
    );
    
    try {
      // Import printing and pdf packages
      final formRepo = FormRepository();
      final forms = await formRepo.getFormsByResident(resident.id);
      
      // For now, show a dialog with export options
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Export Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Export ${resident.fullName}\'s profile data?'),
                const SizedBox(height: 16),
                Text(
                  '• Basic Information\n• Medical Information\n• ${forms.length} Form(s)',
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _generateProfilePdf(resident, forms);
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _generateProfilePdf(
    ResidentModel resident,
    List<FormSubmissionModel> forms,
  ) async {
    try {
      // Use the printing package to generate PDF
      final pdf = await _buildProfilePdf(resident, forms);
      
      // Import printing functionality
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
        name: '${resident.fullName}_Profile',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<Uint8List> _buildProfilePdf(
    ResidentModel resident,
    List<FormSubmissionModel> forms,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'RESIDENT PROFILE',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Resident Name
          pw.Text(
            resident.fullName,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Basic Information
          pw.Header(level: 1, child: pw.Text('Basic Information')),
          _pdfInfoRow('Date of Birth', DateFormat('MMMM d, yyyy').format(resident.dateOfBirth)),
          _pdfInfoRow('Age', '${resident.age} years'),
          _pdfInfoRow('Gender', resident.gender),
          _pdfInfoRow('Admission Date', DateFormat('MMMM d, yyyy').format(resident.admissionDate)),
          pw.SizedBox(height: 20),
          
          // Emergency Contact
          if (resident.emergencyContactName != null) ...[
            pw.Header(level: 1, child: pw.Text('Emergency Contact')),
            _pdfInfoRow('Name', resident.emergencyContactName!),
            if (resident.emergencyContactPhone != null)
              _pdfInfoRow('Phone', resident.emergencyContactPhone!),
            if (resident.emergencyContactRelation != null)
              _pdfInfoRow('Relationship', resident.emergencyContactRelation!),
            pw.SizedBox(height: 20),
          ],
          
          // Medical Information
          pw.Header(level: 1, child: pw.Text('Medical Information')),
          if (resident.primaryDiagnosis != null)
            _pdfInfoRow('Primary Diagnosis', resident.primaryDiagnosis!),
          if (resident.allergies != null)
            _pdfInfoRow('Allergies', resident.allergies!),
          if (resident.medicalNotes != null)
            _pdfInfoRow('Notes', resident.medicalNotes!),
          pw.SizedBox(height: 20),
          
          // Forms Summary
          pw.Header(level: 1, child: pw.Text('Forms History')),
          pw.Text('Total Forms: ${forms.length}'),
          pw.SizedBox(height: 10),
          if (forms.isNotEmpty) ...[
            pw.Table.fromTextArray(
              headers: ['Form Type', 'Date', 'Status'],
              data: forms.map((f) => [
                _getFormDisplayName(f.templateType),
                DateFormat('MMM d, yyyy').format(f.createdAt),
                f.status.toUpperCase(),
              ]).toList(),
            ),
          ],
        ],
      ),
    );
    
    return pdf.save();
  }
  
  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
  
  void _showWardTransferDialog(BuildContext context, ResidentModel resident) {
    String? selectedWardId = resident.currentWardId;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transfer Ward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer ${resident.fullName} to a different ward:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: context.read<ResidentRepository>().getWards(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Failed to load wards');
                }
                final wards = snapshot.data!;
                return StatefulBuilder(
                  builder: (context, setDialogState) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedWardId,
                      decoration: const InputDecoration(
                        labelText: 'Select Ward',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: wards.map((ward) {
                        return DropdownMenuItem(
                          value: ward.id,
                          child: Text(ward.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedWardId = value);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedWardId != null && selectedWardId != resident.currentWardId) {
                Navigator.pop(dialogContext);
                await _transferResident(resident, selectedWardId!);
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _transferResident(ResidentModel resident, String newWardId) async {
    try {
      final repository = context.read<ResidentRepository>();
      await repository.updateResident(
        id: resident.id,
        wardId: newWardId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resident transferred successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadResident(); // Refresh the data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to transfer: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
  
  Widget _buildRecentFormsSection(BuildContext context, ResidentModel resident) {
    return FutureBuilder<List<FormSubmissionModel>>(
      future: FormRepository().getFormsByResident(resident.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final forms = snapshot.data ?? [];
        
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
                    const Icon(Icons.folder_open, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Forms',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (forms.isNotEmpty)
                      TextButton(
                        onPressed: () => _showResidentForms(context, resident),
                        child: Text('See All (${forms.length})'),
                      ),
                  ],
                ),
                const Divider(height: 24),
                if (forms.isEmpty)
                  const Text(
                    'No forms created yet',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  // Show last 3 forms
                  ...forms.take(3).map((form) => _buildFormTile(context, form)),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFormTile(BuildContext context, FormSubmissionModel form) {
    final statusColor = _getStatusColor(form.status);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.description,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        _getFormDisplayName(form.templateType),
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('MMM d, yyyy').format(form.createdAt),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          form.status.toUpperCase(),
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        context.push('/forms/${form.id}');
      },
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'submitted':
      case 'pending_review':
        return AppColors.warning;
      case 'returned':
        return AppColors.error;
      case 'draft':
      default:
        return AppColors.textSecondary;
    }
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

/// Bottom sheet showing all forms for a resident
class _ResidentFormsSheet extends StatelessWidget {
  final ResidentModel resident;
  
  const _ResidentFormsSheet({required this.resident});
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
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
                    const Icon(Icons.folder_open, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Forms for ${resident.firstName}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All submitted and draft forms',
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
              // Forms list
              Expanded(
                child: FutureBuilder<List<FormSubmissionModel>>(
                  future: FormRepository().getFormsByResident(resident.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final forms = snapshot.data ?? [];
                    
                    if (forms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No forms yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Forms created for this resident will appear here',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: forms.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final form = forms[index];
                        return _FormListItem(form: form);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormListItem extends StatelessWidget {
  final FormSubmissionModel form;
  
  const _FormListItem({required this.form});
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'submitted':
      case 'pending_review':
        return AppColors.warning;
      case 'returned':
        return AppColors.error;
      case 'draft':
      default:
        return AppColors.textSecondary;
    }
  }
  
  String _getFormDisplayName(String templateType) {
    final template = FormTemplatesRegistry.getById(templateType);
    if (template != null) {
      return template.name;
    }
    return templateType
        .replaceAll(RegExp(r'^(ss_|hl_|ps_|med_|rehab_)'), '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(form.status);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.description,
          color: statusColor,
          size: 24,
        ),
      ),
      title: Text(
        _getFormDisplayName(form.templateType),
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM d, yyyy • h:mm a').format(form.createdAt),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          form.status.toUpperCase().replaceAll('_', ' '),
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close the sheet
        context.push('/forms/${form.id}');
      },
    );
  }
}
