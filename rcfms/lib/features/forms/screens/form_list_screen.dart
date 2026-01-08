import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/form_submission_model.dart';
import '../../../data/repositories/form_repository.dart';
import '../../auth/bloc/auth_bloc.dart';

class FormListScreen extends StatefulWidget {
  const FormListScreen({super.key});

  @override
  State<FormListScreen> createState() => _FormListScreenState();
}

class _FormListScreenState extends State<FormListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FormSubmissionModel> _allForms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    });

    try {
      final repository = context.read<FormRepository>();
      final forms = await repository.getMyForms();
      setState(() {
        _allForms = forms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FormSubmissionModel> _getFilteredForms(String? status) {
    if (status == null) return _allForms;
    return _allForms.where((f) => f.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userUnit = authState is AuthAuthenticated ? authState.user.unit : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Forms'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Drafts'),
            Tab(text: 'Pending'),
            Tab(text: 'Returned'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFormList(null),
                _buildFormList(AppConstants.statusDraft),
                _buildFormList(AppConstants.statusPendingReview),
                _buildFormList(AppConstants.statusReturned),
              ],
            ),
      floatingActionButton: userUnit != null
          ? FloatingActionButton.extended(
              onPressed: () => _showNewFormDialog(context, userUnit),
              icon: const Icon(Icons.add),
              label: const Text('New Form'),
            )
          : null,
    );
  }

  Widget _buildFormList(String? status) {
    final forms = _getFilteredForms(status);

    if (forms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              status == null ? 'No forms yet' : 'No ${_getStatusLabel(status)} forms',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForms,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: forms.length,
        itemBuilder: (context, index) {
          final form = forms[index];
          return _FormCard(
            form: form,
            onTap: () {
              if (form.canEdit) {
                context.push('/forms/fill/${form.templateType}?formId=${form.id}&unit=${form.unit}');
              } else {
                context.push('/forms/view/${form.id}');
              }
            },
          );
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case AppConstants.statusDraft:
        return 'draft';
      case AppConstants.statusPendingReview:
        return 'pending';
      case AppConstants.statusReturned:
        return 'returned';
      default:
        return status;
    }
  }

  void _showNewFormDialog(BuildContext context, String unit) {
    final formTypes = AppConstants.formTypesByUnit[unit] ?? [];

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
                'Create New Form',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a resident first by scanning or browsing',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _FormTypeCard(
                      icon: Icons.nfc,
                      label: 'Scan Ward',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/scan');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormTypeCard(
                      icon: Icons.people,
                      label: 'Browse',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/residents');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: form.unitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description,
                      color: form.unitColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.templateDisplayName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          form.residentName ?? 'Unknown Resident',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: form.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(form.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  if (form.isReturned && form.reviewComment != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment,
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        form.reviewComment!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case AppConstants.statusDraft:
        color = AppColors.statusDraft;
        label = 'Draft';
        break;
      case AppConstants.statusPendingReview:
        color = AppColors.statusPendingReview;
        label = 'Pending';
        break;
      case AppConstants.statusApproved:
        color = AppColors.statusApproved;
        label = 'Approved';
        break;
      case AppConstants.statusReturned:
        color = AppColors.statusReturned;
        label = 'Returned';
        break;
      default:
        color = AppColors.statusDraft;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FormTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FormTypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
