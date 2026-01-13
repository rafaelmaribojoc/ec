import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/form_submission_model.dart';
import '../../../data/repositories/form_repository.dart';

class FormViewScreen extends StatefulWidget {
  final String formId;

  const FormViewScreen({super.key, required this.formId});

  @override
  State<FormViewScreen> createState() => _FormViewScreenState();
}

class _FormViewScreenState extends State<FormViewScreen> {
  FormSubmissionModel? _form;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final formRepo = context.read<FormRepository>();
      final form = await formRepo.getFormById(widget.formId);
      setState(() {
        _form = form;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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

    if (_form == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Form'),
        ),
        body: const Center(child: Text('Form not found')),
      );
    }

    final form = _form!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(form.templateDisplayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Export PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(form),
            const SizedBox(height: 20),

            // Resident info
            _buildSection(
              'Resident',
              [
                _buildInfoRow('Name', form.residentName ?? 'Unknown'),
              ],
            ),
            const SizedBox(height: 16),

            // Form data
            _buildSection(
              'Form Details',
              _buildFormDataFields(form.formData),
            ),
            const SizedBox(height: 16),

            // Signatures
            _buildSignaturesSection(form),
            const SizedBox(height: 16),

            // Review comment (if returned)
            if (form.isReturned && form.reviewComment != null)
              _buildReturnedSection(form),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(FormSubmissionModel form) {
    return Card(
      color: form.statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(form.status),
              color: form.statusColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.statusDisplayText,
                    style: TextStyle(
                      color: form.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted ${_formatDate(form.submittedAt ?? form.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: form.unitColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                form.unit.toUpperCase(),
                style: TextStyle(
                  color: form.unitColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.edit;
      case 'pending_review':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'returned':
        return Icons.replay;
      default:
        return Icons.description;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormDataFields(Map<String, dynamic> formData) {
    final fields = <Widget>[];
    formData.forEach((key, value) {
      if (value == null || key.startsWith('_')) return;
      
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
        displayValue = value.isEmpty ? '-' : '${value.length} items';
      } else if (value is Map) {
        displayValue = 'Complex data';
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else {
        displayValue = value?.toString() ?? '-';
      }
      
      fields.add(_buildInfoRow(label, displayValue));
    });
    
    return fields.isEmpty 
        ? [const Text('No data available')]
        : fields;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildSignaturesSection(FormSubmissionModel form) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signatures',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            // Submitter signature
            _buildSignatureBlock(
              'Submitted by',
              form.submitterName ?? 'Unknown',
              form.submitterSignatureUrl,
              form.submittedAt,
            ),
            // Reviewer signature
            if (form.reviewedBy != null) ...[
              const SizedBox(height: 16),
              _buildSignatureBlock(
                form.isApproved ? 'Approved by' : 'Reviewed by',
                form.reviewerName ?? 'Unknown',
                form.reviewerSignatureUrl,
                form.reviewedAt,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureBlock(
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
                  _formatDate(timestamp),
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

  Widget _buildReturnedSection(FormSubmissionModel form) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppColors.error),
                const SizedBox(width: 8),
                Text(
                  'Return Comment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              form.reviewComment!,
              style: const TextStyle(color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/forms/fill/${form.templateType}?formId=${form.id}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Edit & Resubmit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}
