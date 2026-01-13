import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/form_submission_model.dart';
import '../../../data/models/form_approval_model.dart';
import '../../../data/repositories/form_repository.dart';
import '../../../data/repositories/approval_repository.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../templates/form_templates.dart';
import '../widgets/form_content_widget.dart';

class FormViewScreen extends StatefulWidget {
  final String formId;

  const FormViewScreen({super.key, required this.formId});

  @override
  State<FormViewScreen> createState() => _FormViewScreenState();
}

class _FormViewScreenState extends State<FormViewScreen> {
  FormSubmissionModel? _form;
  bool _isLoading = true;
  bool _isActioning = false;

  // Action info
  bool _canAct = false;
  String? _actionType;
  FormApprovalModel? _pendingApproval;
  String? _signatureFieldName;

  final ApprovalRepository _approvalRepository = ApprovalRepository();

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() => _isLoading = true);
    try {
      final formRepo = context.read<FormRepository>();
      final form = await formRepo.getFormById(widget.formId);

      // Check if current user can take action on this form
      final actionInfo =
          await _approvalRepository.getFormActionInfo(widget.formId);

      setState(() {
        _form = form;
        _canAct = actionInfo['canAct'] as bool;
        _actionType = actionInfo['actionType'] as String?;
        _pendingApproval = actionInfo['approval'] as FormApprovalModel?;
        _signatureFieldName = actionInfo['signatureFieldName'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading form: $e');
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

    // Try to get the template for consistent UI - use unit to get correct template
    final template =
        FormTemplatesRegistry.getByTypeAndUnit(form.templateType, form.unit) ??
            FormTemplatesRegistry.getByType(form.templateType);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(form.templateDisplayName),
        backgroundColor: template != null
            ? AppColors.getServiceUnitColor(template.serviceUnit.name)
            : null,
        foregroundColor: template != null ? Colors.white : null,
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

            // Use shared form content widget if template is available
            if (template != null)
              FormContentWidget(
                template: template,
                formData: form.formData,
                isReadOnly: true,
                residentName: form.residentName,
                existingSubmission: form,
                showSignatures: true,
              )
            else ...[
              // Fallback to original layout if template not found
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
            ],

            const SizedBox(height: 16),

            // Review comment (if returned)
            if (form.isReturned && form.reviewComment != null)
              _buildReturnedSection(form),

            // Add bottom padding for action buttons
            if (_canAct) const SizedBox(height: 80),
          ],
        ),
      ),
      // Dynamic action buttons
      bottomNavigationBar: _canAct ? _buildActionButtons(form) : null,
    );
  }

  /// Build dynamic action buttons based on user role and form type
  Widget _buildActionButtons(FormSubmissionModel form) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Return button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isActioning ? null : () => _showReturnDialog(),
                icon: const Icon(Icons.replay),
                label: const Text('Return'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Approve/Acknowledge button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isActioning ? null : () => _handleAction(),
                icon: _isActioning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_getActionIcon()),
                label: Text(_getActionButtonLabel()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the appropriate action button label based on action type
  String _getActionButtonLabel() {
    if (_signatureFieldName != null) {
      // Has a specific signature field - determine label from field name
      final fieldLower = _signatureFieldName!.toLowerCase();
      if (fieldLower.contains('noted') || fieldLower.contains('note')) {
        return 'Note';
      } else if (fieldLower.contains('approved') ||
          fieldLower.contains('approve')) {
        return 'Approve';
      } else if (fieldLower.contains('received') ||
          fieldLower.contains('receive')) {
        return 'Receive';
      }
      return 'Sign';
    }

    // Based on action type
    switch (_actionType) {
      case 'approve':
        return 'Approve';
      case 'acknowledge':
        return 'Acknowledge';
      default:
        return 'Confirm';
    }
  }

  /// Get the appropriate action icon
  IconData _getActionIcon() {
    if (_signatureFieldName != null) {
      return Icons.draw; // Signature required
    }
    switch (_actionType) {
      case 'approve':
        return Icons.check_circle;
      case 'acknowledge':
        return Icons.thumb_up;
      default:
        return Icons.check;
    }
  }

  /// Handle the action button press
  Future<void> _handleAction() async {
    if (_pendingApproval == null) return;

    setState(() => _isActioning = true);

    try {
      Map<String, dynamic>? signatureInfo;
      Map<String, dynamic>? acknowledgeInfo;

      if (_signatureFieldName != null) {
        // Requires signature - determine action type from field name
        final fieldLower = _signatureFieldName!.toLowerCase();
        if (fieldLower.contains('noted') || fieldLower.contains('note')) {
          signatureInfo = await _approvalRepository.noteFormWithAutoSignature(
            approvalId: _pendingApproval!.id,
          );
        } else {
          signatureInfo =
              await _approvalRepository.approveFormWithAutoSignature(
            approvalId: _pendingApproval!.id,
          );
        }
      } else if (_actionType == 'approve') {
        signatureInfo = await _approvalRepository.approveFormWithAutoSignature(
          approvalId: _pendingApproval!.id,
        );
      } else {
        // Simple acknowledge without signature
        acknowledgeInfo = await _approvalRepository.acknowledgeFormSimple(
          approvalId: _pendingApproval!.id,
        );
      }

      if (mounted) {
        // Update the local form state
        if (_form != null) {
          if (signatureInfo != null) {
            // Update with signature info
            setState(() {
              _form = _form!.copyWith(
                status: 'approved',
                reviewedBy: signatureInfo!['signerId'] as String?,
                reviewerName: signatureInfo['signerName'] as String?,
                reviewerSignatureUrl: signatureInfo['signatureUrl'] as String?,
                reviewedAt: signatureInfo['signedAt'] as DateTime?,
              );
              _canAct = false;
              _pendingApproval = null;
            });
          } else if (acknowledgeInfo != null) {
            // Update for simple acknowledge (no signature)
            setState(() {
              _form = _form!.copyWith(
                status: 'approved',
                reviewedBy: acknowledgeInfo!['acknowledgedBy'] as String?,
                reviewerName: acknowledgeInfo['acknowledgerName'] as String?,
                reviewedAt: acknowledgeInfo['acknowledgedAt'] as DateTime?,
              );
              _canAct = false;
              _pendingApproval = null;
            });
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Form ${_getActionButtonLabel().toLowerCase()}d successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActioning = false);
      }
    }
  }

  /// Show return dialog for entering comment
  Future<void> _showReturnDialog() async {
    if (_pendingApproval == null) return;

    final commentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Form'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for returning this form:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your comments...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a comment')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isActioning = true);
      try {
        await _approvalRepository.returnForm(
          approvalId: _pendingApproval!.id,
          comment: commentController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form returned successfully'),
              backgroundColor: AppColors.warning,
            ),
          );
          await _loadForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isActioning = false);
        }
      }
    }
    commentController.dispose();
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

    return fields.isEmpty ? [const Text('No data available')] : fields;
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
    // Check if current user is the original author
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;
    final isAuthor = currentUserId != null && form.submittedBy == currentUserId;

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
            // Only show Edit & Resubmit button for the original author
            if (isAuthor) ...[
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}
