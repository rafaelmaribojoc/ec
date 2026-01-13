import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/form_submission_model.dart';
import '../templates/form_templates.dart';

/// A shared widget that displays form content.
/// Can be used in both create mode (editable) and view mode (read-only).
class FormContentWidget extends StatelessWidget {
  /// The form template
  final FormTemplate template;

  /// The form data (current values)
  final Map<String, dynamic> formData;

  /// Callback when a field value changes (null for read-only mode)
  final void Function(String key, dynamic value)? onFieldChanged;

  /// Whether the form is read-only
  final bool isReadOnly;

  /// Optional resident name to display
  final String? residentName;

  /// Optional resident case number
  final String? caseNumber;

  /// Existing form submission data (for view mode with signatures)
  final FormSubmissionModel? existingSubmission;

  /// Whether to show the signature section
  final bool showSignatures;

  const FormContentWidget({
    super.key,
    required this.template,
    required this.formData,
    this.onFieldChanged,
    this.isReadOnly = false,
    this.residentName,
    this.caseNumber,
    this.existingSubmission,
    this.showSignatures = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        return ResponsiveContainer(
          maxWidth: screen.value(
            mobile: double.infinity,
            tablet: 800.0,
            desktop: 900.0,
          ),
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
                  _buildFormHeader(context, screen),
                  const Divider(height: 32),

                  // Form fields
                  ..._buildFormFields(context, screen),

                  // Signatures section (only in view mode)
                  if (showSignatures && existingSubmission != null) ...[
                    const SizedBox(height: 24),
                    _buildSignaturesSection(context, screen),
                  ],

                  SizedBox(
                    height: screen.value(mobile: 16.0, tablet: 20.0, desktop: 24.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormHeader(BuildContext context, ScreenInfo screen) {
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
                color: AppColors.getServiceUnitColor(template.serviceUnit.name)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                template.icon,
                color: AppColors.getServiceUnitColor(template.serviceUnit.name),
                size: screen.value(mobile: 24.0, tablet: 28.0, desktop: 32.0),
              ),
            ),
            SizedBox(
              width: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(
                      fontSize:
                          screen.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.serviceUnit.displayName,
                    style: TextStyle(
                      fontSize:
                          screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (residentName != null) ...[
          SizedBox(
            height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                residentName!,
                style: TextStyle(
                  fontSize:
                      screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (caseNumber != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.folder, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Case #: $caseNumber',
                  style: TextStyle(
                    fontSize:
                        screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
        if (template.description.isNotEmpty) ...[
          SizedBox(
            height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          Text(
            template.description,
            style: TextStyle(
              fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFormFields(BuildContext context, ScreenInfo screen) {
    if (isReadOnly) {
      // View mode: Display form data as read-only fields
      return _buildReadOnlyFields(context, screen);
    } else {
      // Edit mode: Use form template's field builders
      return FormTemplatesRegistry.getFormFields(
        template,
        formData,
        onFieldChanged ?? (_, __) {},
      );
    }
  }

  List<Widget> _buildReadOnlyFields(BuildContext context, ScreenInfo screen) {
    final fields = <Widget>[];

    // Fields to hide from approver view (internal/auto-populated data)
    final hiddenFields = {
      'created_at',
      'template_id',
      'service_unit',
      'prepared_by_id',
      'noted_by_id',
      'submitted_to_id',
      'submitted_to_name',
      // Hide auto-populated fields that are shown in signatures section
      'prepared_by',
      'prepared_by_position',
      'noted_by',
      'noted_by_position',
      'license_no',
      // Hide fields not directly related to the form content
      'contact_person',
      'contact_number',
      'relationship',
      'emergency_contact_name',
      'emergency_contact_phone',
      'emergency_contact_relation',
      'primary_diagnosis',
      'diagnosis',
      // Hide resident metadata (shown in header)
      'resident_code',
      'case_no',
      'dob',
      'date_of_birth',
      'age',
      'gender',
      'sex',
      'ward',
      'current_ward',
      'room_no',
      'bed_no',
      'admission_date',
      'date_admitted',
    };

    formData.forEach((key, value) {
      if (value == null || key.startsWith('_')) return;
      if (hiddenFields.contains(key)) return;
      
      // Skip empty values
      final strValue = value.toString();
      if (strValue.isEmpty || strValue == 'null') return;

      // Format the key to be more readable
      final label = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '')
          .join(' ');

      // Format the value based on type
      String displayValue;
      if (value is List) {
        if (value.isEmpty) {
          return; // Skip empty lists
        } else if (value.first is Map) {
          // Complex list (e.g., checklist items)
          displayValue = '${value.length} items';
        } else {
          displayValue = value.join(', ');
        }
      } else if (value is Map) {
        return; // Skip complex maps
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else if (value is DateTime) {
        displayValue = DateFormat('MMM d, yyyy').format(value);
      } else {
        displayValue = strValue;
      }

      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
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
                  displayValue,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return fields.isEmpty
        ? [const Text('No data available')]
        : fields;
  }

  Widget _buildSignaturesSection(BuildContext context, ScreenInfo screen) {
    final form = existingSubmission!;

    // Get Prepared By and Noted By from form data
    final preparedByName = formData['prepared_by']?.toString();
    final preparedByPosition = formData['prepared_by_position']?.toString();
    final notedByName = formData['noted_by']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signatures',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Divider(height: 24),
        
        // Prepared By signature (from form data)
        if (preparedByName != null && preparedByName.isNotEmpty) ...[
          _buildFormDataSignatureBlock(
            context,
            'Prepared By',
            preparedByName,
            preparedByPosition,
            form.submitterSignatureUrl, // Use submitter's signature
          ),
          const SizedBox(height: 16),
        ],
        
        // Submitter signature
        _buildSignatureBlock(
          context,
          'Submitted by',
          form.submitterName ?? 'Unknown',
          form.submitterSignatureUrl,
          form.submittedAt,
        ),
        
        // Noted By / Reviewer signature
        if (form.reviewedBy != null || (notedByName != null && notedByName.isNotEmpty)) ...[
          const SizedBox(height: 16),
          _buildSignatureBlock(
            context,
            notedByName != null ? 'Noted By' : (form.isApproved ? 'Approved by' : 'Reviewed by'),
            form.reviewerName ?? notedByName ?? 'Unknown',
            form.reviewerSignatureUrl,
            form.reviewedAt,
          ),
        ],
      ],
    );
  }

  Widget _buildFormDataSignatureBlock(
    BuildContext context,
    String label,
    String name,
    String? position,
    String? signatureUrl,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (position != null && position.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  position,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (signatureUrl != null && signatureUrl.isNotEmpty)
          Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CachedNetworkImage(
              imageUrl: signatureUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.draw,
                color: AppColors.textSecondaryLight,
              ),
            ),
          )
        else
          Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'Pending',
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignatureBlock(
    BuildContext context,
    String label,
    String name,
    String? signatureUrl,
    DateTime? timestamp,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (signatureUrl != null)
          Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CachedNetworkImage(
              imageUrl: signatureUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.draw,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
      ],
    );
  }
}
