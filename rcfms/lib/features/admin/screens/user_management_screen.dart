import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _adminRepo.getAllUsers();
      setState(() {
        _users = users;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
          return _UserCard(
            user: user,
            onTap: () => _showUserDetails(user),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.people_outline,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No users yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first user to get started',
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
              'Failed to load users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final nameController = TextEditingController();
      final workIdController = TextEditingController();
    String selectedRole = 'operator';
    String selectedUnit = 'social';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New User',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Create a new staff account',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Email
                      Text('Email', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'user@example.com',
                          prefixIcon: Icon(Icons.mail_outline, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      Text('Full Name', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Juan Dela Cruz',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Work ID
                      Text('Work ID', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: workIdController,
                        decoration: const InputDecoration(
                          hintText: 'EMP-001',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Work ID is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Role
                      Text('Role', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'operator', child: Text('Operator')),
                          DropdownMenuItem(value: 'specialist', child: Text('Specialist')),
                          DropdownMenuItem(value: 'reviewer', child: Text('Reviewer')),
                          DropdownMenuItem(value: 'signatory', child: Text('Signatory')),
                          DropdownMenuItem(value: 'center_head', child: Text('Center Head')),
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                        ],
                        onChanged: (v) => setDialogState(() => selectedRole = v!),
                      ),
                      const SizedBox(height: 20),

                      // Unit
                      Text('Service Unit', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'social', child: Text('Social Service')),
                          DropdownMenuItem(value: 'homelife', child: Text('Home Life Service')),
                          DropdownMenuItem(value: 'psych', child: Text('Psychological Service')),
                          DropdownMenuItem(value: 'medical', child: Text('Medical Service')),
                          DropdownMenuItem(value: 'rehab', child: Text('Rehabilitation Service')),
                        ],
                        onChanged: (v) => setDialogState(() => selectedUnit = v!),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                Navigator.pop(context);
                                _createUser(
                                  email: emailController.text.trim(),
                                  fullName: nameController.text.trim(),
                                  workId: workIdController.text.trim(),
                                  role: selectedRole,
                                  unit: selectedUnit,
                                );
                              },
                              child: const Text('Create User'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createUser({
    required String email,
    required String fullName,
    required String workId,
    required String role,
    required String unit,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await _adminRepo.provisionUser(
        email: email,
        fullName: fullName,
        workId: workId,
        role: role,
        unit: unit,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show credentials dialog
        _showCredentialsDialog(
          email: email,
          password: result.tempPassword,
        );

        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCredentialsDialog({
    required String email,
    required String password,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'User Created Successfully',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Share these credentials with the new user:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Credentials card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _CredentialRow(
                      label: 'Email',
                      value: email,
                    ),
                    const Divider(height: 24),
                    _CredentialRow(
                      label: 'Password',
                      value: password,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The user should change their password after first login.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warningLight,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user.fullName),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            _RoleBadge(role: user.role),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Details
                  _DetailRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Work ID',
                    value: user.workId,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.business_outlined,
                    label: 'Unit',
                    value: _formatUnit(user.unit ?? 'N/A'),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created',
                    value: user.createdAt != null
                        ? DateFormat('MMM d, y').format(user.createdAt!)
                        : 'N/A',
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement edit
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement deactivate
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          icon: const Icon(Icons.block_outlined),
                          label: const Text('Deactivate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatUnit(String unit) {
    switch (unit) {
      case 'social':
        return 'Social Service';
      case 'homelife':
        return 'Home Life Service';
      case 'psych':
        return 'Psychological Service';
      case 'medical':
        return 'Medical Service';
      case 'rehab':
        return 'Rehabilitation Service';
      default:
        return unit;
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    _getInitials(user.fullName),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _RoleBadge(role: user.role),
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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = _getRoleStyle(role);

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

  (Color, Color, String) _getRoleStyle(String role) {
    switch (role) {
      case 'super_admin':
        return (
          AppColors.error,
          AppColors.errorSurface,
          'Super Admin',
        );
      case 'center_head':
        return (
          AppColors.unitPsych,
          AppColors.unitPsychSurface,
          'Center Head',
        );
      case 'reviewer':
        return (
          AppColors.warning,
          AppColors.warningSurface,
          'Reviewer',
        );
      case 'specialist':
        return (
          AppColors.success,
          AppColors.successSurface,
          'Specialist',
        );
      case 'signatory':
        return (
          AppColors.info,
          AppColors.infoSurface,
          'Signatory',
        );
      default:
        return (
          AppColors.textSecondary,
          AppColors.surfaceHover,
          'Operator',
        );
    }
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied to clipboard'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(
            Icons.copy,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
