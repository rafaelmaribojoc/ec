import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../templates/form_templates.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/repositories/form_repository.dart';
import '../../../data/repositories/approval_repository.dart';
import '../../../data/models/form_submission_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'form_pdf_preview_screen.dart';

/// Responsive form filling screen
class FormFillScreen extends StatefulWidget {
  final FormTemplate template;
  final String residentId;
  final String residentName;
  final String? caseNumber;
  final Map<String, dynamic>? initialData;
  final String? existingSubmissionId;
  final bool isEditing;

  /// Resident data for smart defaults (auto-population)
  final Map<String, dynamic>? residentData;

  const FormFillScreen({
    super.key,
    required this.template,
    required this.residentId,
    required this.residentName,
    this.caseNumber,
    this.initialData,
    this.existingSubmissionId,
    this.isEditing = false,
    this.residentData,
  });

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  late Map<String, dynamic> _formData;
  final _formKey = GlobalKey<FormState>();
  bool _isDirty = false;
  bool _isSaving = false;
  String? _submissionId;

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData != null
        ? Map<String, dynamic>.from(widget.initialData!)
        : FormTemplatesRegistry.getDefaultData(
            widget.template,
            residentData: widget.residentData,
          );
    _submissionId = widget.existingSubmissionId;
  }

  /// Get the database unit from the service unit
  String get _databaseUnit => AppConstants.getUnitFromServiceUnit(
        widget.template.serviceUnit.name,
      );

  void _updateField(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        return PopScope(
          canPop: !_isDirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _showExitConfirmation(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(screen),
            body: _buildBody(screen),
            bottomNavigationBar: _buildBottomBar(screen),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ScreenInfo screen) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.template.name,
            style: TextStyle(
              fontSize: screen.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
            ),
          ),
          Text(
            widget.residentName,
            style: TextStyle(
              fontSize: screen.value(mobile: 12.0, tablet: 13.0, desktop: 14.0),
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      backgroundColor:
          AppColors.getServiceUnitColor(widget.template.serviceUnit.name),
      foregroundColor: AppColors.textOnPrimary,
      toolbarHeight: screen.value(mobile: 64.0, tablet: 68.0, desktop: 72.0),
      actions: _buildAppBarActions(screen),
    );
  }

  List<Widget> _buildAppBarActions(ScreenInfo screen) {
    if (screen.isMobile) {
      return [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'preview',
              child: ListTile(
                leading: Icon(Icons.preview),
                title: Text('Preview PDF'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'save_draft',
              child: ListTile(
                leading: Icon(Icons.save_outlined),
                title: Text('Save Draft'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (_isDirty)
              const PopupMenuItem(
                value: 'discard',
                child: ListTile(
                  leading: Icon(Icons.restore, color: Colors.red),
                  title: Text('Discard Changes',
                      style: TextStyle(color: Colors.red)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ];
    }

    return [
      TextButton.icon(
        onPressed: _previewPdf,
        icon: const Icon(Icons.preview, color: Colors.white70),
        label: Text(
          'Preview',
          style: TextStyle(
            color: Colors.white70,
            fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
          ),
        ),
      ),
      const SizedBox(width: 8),
      TextButton.icon(
        onPressed: _saveDraft,
        icon: const Icon(Icons.save_outlined, color: Colors.white),
        label: Text(
          'Save Draft',
          style: TextStyle(
            color: Colors.white,
            fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
          ),
        ),
      ),
      const SizedBox(width: 16),
    ];
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'preview':
        _previewPdf();
        break;
      case 'save_draft':
        _saveDraft();
        break;
      case 'discard':
        _discardChanges();
        break;
    }
  }

  Widget _buildBody(ScreenInfo screen) {
    return Form(
      key: _formKey,
      child: ResponsiveContainer(
        maxWidth: screen.value(
            mobile: double.infinity, tablet: 800.0, desktop: 900.0),
        padding: EdgeInsets.symmetric(
          horizontal: screen.horizontalPadding,
          vertical: screen.value(mobile: 16.0, tablet: 20.0, desktop: 24.0),
        ),
        child: SingleChildScrollView(
          child: ResponsiveCard(
            padding: EdgeInsets.all(
              screen.value(mobile: 16.0, tablet: 20.0, desktop: 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form header
                _buildFormHeader(screen),
                const Divider(height: 32),
                // Form fields
                ...FormTemplatesRegistry.getFormFields(
                  widget.template,
                  _formData,
                  _updateField,
                ),
                SizedBox(
                    height: screen.value(
                        mobile: 16.0, tablet: 20.0, desktop: 24.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(ScreenInfo screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                screen.value(mobile: 8.0, tablet: 10.0, desktop: 12.0),
              ),
              decoration: BoxDecoration(
                color: AppColors.getServiceUnitColor(
                        widget.template.serviceUnit.name)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.template.icon,
                color: AppColors.getServiceUnitColor(
                    widget.template.serviceUnit.name),
                size: screen.value(mobile: 24.0, tablet: 28.0, desktop: 32.0),
              ),
            ),
            SizedBox(
                width: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: TextStyle(
                      fontSize: screen.value(
                          mobile: 18.0, tablet: 20.0, desktop: 22.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.template.serviceUnit.displayName,
                    style: TextStyle(
                      fontSize: screen.value(
                          mobile: 13.0, tablet: 14.0, desktop: 15.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.template.description.isNotEmpty) ...[
          SizedBox(
              height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
          Text(
            widget.template.description,
            style: TextStyle(
              fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(ScreenInfo screen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screen.horizontalPadding,
        vertical: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: screen.isMobile
            ? _buildMobileBottomBar(screen)
            : _buildDesktopBottomBar(screen),
      ),
    );
  }

  Widget _buildMobileBottomBar(ScreenInfo screen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator
        if (_isDirty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'Unsaved changes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previewPdf,
                child: const Text('Preview'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopBottomBar(ScreenInfo screen) {
    return Row(
      children: [
        // Status
        if (_isDirty)
          Row(
            children: [
              Icon(Icons.edit, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                'Unsaved changes',
                style: TextStyle(color: AppColors.warning),
              ),
            ],
          ),
        const Spacer(),
        // Actions
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _previewPdf,
          icon: const Icon(Icons.preview),
          label: const Text('Preview PDF'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _submitForm,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check),
          label: Text(_isSaving ? 'Submitting...' : 'Submit Form'),
        ),
      ],
    );
  }

  void _previewPdf() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormPdfPreviewScreen(
          template: widget.template,
          formData: _formData,
          residentName: widget.residentName,
          caseNumber: widget.caseNumber,
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    setState(() => _isSaving = true);

    try {
      final formRepository = context.read<FormRepository>();
      FormSubmissionModel submission;

      if (_submissionId != null) {
        // Update existing draft
        submission = await formRepository.updateDraft(
          id: _submissionId!,
          formData: _formData,
        );
      } else {
        // Create new draft
        submission = await formRepository.createDraft(
          residentId: widget.residentId,
          templateId: widget.template.id,
          templateType: widget.template.templateType,
          unit: _databaseUnit,
          formData: _formData,
        );
        _submissionId = submission.id;
      }

      setState(() {
        _isDirty = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show recipient selector
    _showSubmitToDialog();
  }

  void _showSubmitToDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _SubmitToDialog(
        onSubmit: (recipientId, recipientName) async {
          Navigator.pop(dialogContext);
          await _doSubmit(recipientId, recipientName);
        },
      ),
    );
  }

  /// Helper to convert empty strings to null for UUID fields
  String? _nullIfEmpty(String? value) => (value?.isEmpty ?? true) ? null : value;

  Future<void> _doSubmit(String? recipientId, String? recipientName) async {
    setState(() => _isSaving = true);

    try {
      final formRepository = context.read<FormRepository>();
      final approvalRepository = ApprovalRepository();

      // Get current user
      final authState = context.read<AuthBloc>().state;
      final currentUser =
          authState is AuthAuthenticated ? authState.user : null;

      // Validate recipient - ensure we have valid data or null
      final safeRecipientId = _nullIfEmpty(recipientId);
      final safeRecipientName = _nullIfEmpty(recipientName);

      // If no submission exists yet, create a draft first
      if (_submissionId == null) {
        final draft = await formRepository.createDraft(
          residentId: widget.residentId,
          templateId: widget.template.id,
          templateType: widget.template.templateType,
          unit: _databaseUnit,
          formData: _formData,
        );
        _submissionId = draft.id;
      }

      // Add recipient info and prepared by info to form data
      // Only add if they have actual values (not empty strings)
      final submissionData = Map<String, dynamic>.from(_formData);
      if (safeRecipientId != null) {
        submissionData['submitted_to_id'] = safeRecipientId;
        submissionData['submitted_to_name'] = safeRecipientName;
      }

      // Auto-populate "Prepared By" with current user info
      if (currentUser != null) {
        submissionData['prepared_by_id'] = _nullIfEmpty(currentUser.id);
        submissionData['prepared_by_name'] = _nullIfEmpty(currentUser.fullName);
        submissionData['prepared_by_title'] = _nullIfEmpty(currentUser.title);
        submissionData['prepared_by_employee_id'] = _nullIfEmpty(currentUser.employeeId);
      }

      // Submit the form for review
      await formRepository.submitForm(
        id: _submissionId!,
        formData: submissionData,
      );

      // Create an approval request if recipient is specified
      if (safeRecipientId != null && safeRecipientName != null && currentUser != null) {
        try {
          await approvalRepository.createApprovalRequest(
            formId: _submissionId!,
            recipientId: safeRecipientId,
            recipientName: safeRecipientName,
            signatureFieldName: 'approved_by', // Default signature field
          );
        } catch (e) {
          // Log but don't fail the submission if approval request fails
          debugPrint('Failed to create approval request: $e');
        }
      }

      setState(() => _isSaving = false);

      if (mounted) {
        final message = safeRecipientName != null
            ? 'Form submitted to $safeRecipientName'
            : 'Form submitted successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit form: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _discardChanges() {
    setState(() {
      _formData = widget.initialData != null
          ? Map<String, dynamic>.from(widget.initialData!)
          : FormTemplatesRegistry.getDefaultData(widget.template);
      _isDirty = false;
    });
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Dialog for selecting a recipient to submit the form to
class _SubmitToDialog extends StatefulWidget {
  final Future<void> Function(String? recipientId, String? recipientName)
      onSubmit;

  const _SubmitToDialog({required this.onSubmit});

  @override
  State<_SubmitToDialog> createState() => _SubmitToDialogState();
}

class _SubmitToDialogState extends State<_SubmitToDialog> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _selectedUserId;
  String? _selectedUserName;
  bool _submitToUnitHead = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final formRepository = context.read<FormRepository>();
      final users = await formRepository.getApprovers();
      setState(() {
        _users = users;
        _isLoading = false;
        // Default select the first unit head if available
        final heads = users
            .where((u) =>
                u['role'] == 'head' ||
                u['role'] == 'center_head' ||
                u['role'] == 'super_admin')
            .toList();
        if (heads.isNotEmpty) {
          _selectedUserId = heads.first['id'];
          _selectedUserName = heads.first['full_name'];
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Form'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select who should review this form:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Quick option: Submit to Unit Head
            CheckboxListTile(
              value: _submitToUnitHead,
              onChanged: (value) {
                setState(() {
                  _submitToUnitHead = value ?? true;
                  if (_submitToUnitHead) {
                    // Auto-select first head
                    final heads = _users
                        .where((u) =>
                            u['role'] == 'head' || u['role'] == 'center_head')
                        .toList();
                    if (heads.isNotEmpty) {
                      _selectedUserId = heads.first['id'];
                      _selectedUserName = heads.first['full_name'];
                    }
                  }
                });
              },
              title: const Text('Submit to Unit Head'),
              subtitle: const Text('Recommended for standard approval'),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 8),

            // Or select specific user
            if (!_submitToUnitHead) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Or select a specific reviewer:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = user['id'] == _selectedUserId;
                      final roleName = _formatRole(user['role'] ?? '');

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceHover,
                          child: Text(
                            (user['full_name'] as String? ?? 'U')[0]
                                .toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        title: Text(user['full_name'] ?? 'Unknown'),
                        subtitle: Text(roleName),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedUserId = user['id'];
                            _selectedUserName = user['full_name'];
                          });
                        },
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedUserId != null
              ? () => widget.onSubmit(_selectedUserId, _selectedUserName)
              : null,
          icon: const Icon(Icons.send),
          label: const Text('Submit'),
        ),
      ],
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'center_head':
        return 'Center Head';
      case 'head':
        return 'Unit Head';
      case 'staff':
        return 'Staff';
      default:
        return role.replaceAll('_', ' ');
    }
  }
}
