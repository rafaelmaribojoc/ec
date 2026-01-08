import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../templates/form_templates.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../../data/repositories/form_repository.dart';
import '../../../data/models/form_submission_model.dart';
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

  const FormFillScreen({
    super.key,
    required this.template,
    required this.residentId,
    required this.residentName,
    this.caseNumber,
    this.initialData,
    this.existingSubmissionId,
    this.isEditing = false,
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
        : FormTemplatesRegistry.getDefaultData(widget.template);
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
      backgroundColor: AppColors.getServiceUnitColor(widget.template.serviceUnit.name),
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
                  title: Text('Discard Changes', style: TextStyle(color: Colors.red)),
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
        maxWidth: screen.value(mobile: double.infinity, tablet: 800.0, desktop: 900.0),
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
                SizedBox(height: screen.value(mobile: 16.0, tablet: 20.0, desktop: 24.0)),
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
                color: AppColors.getServiceUnitColor(widget.template.serviceUnit.name)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.template.icon,
                color: AppColors.getServiceUnitColor(widget.template.serviceUnit.name),
                size: screen.value(mobile: 24.0, tablet: 28.0, desktop: 32.0),
              ),
            ),
            SizedBox(width: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: TextStyle(
                      fontSize: screen.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.template.serviceUnit.displayName,
                    style: TextStyle(
                      fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.template.description.isNotEmpty) ...[
          SizedBox(height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

    setState(() => _isSaving = true);

    try {
      final formRepository = context.read<FormRepository>();
      
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

      // Submit the form for review
      await formRepository.submitForm(
        id: _submissionId!,
        formData: _formData,
      );
      
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully'),
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
