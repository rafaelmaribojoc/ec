import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _adminRepo = AdminRepository();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminRepo.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final workIdController = TextEditingController();
    String selectedRole = AppConstants.roleSocialStaff;
    String? selectedUnit;
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Provision New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: workIdController,
                  decoration: const InputDecoration(
                    labelText: 'Work ID *',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: [
                    AppConstants.roleSuperAdmin,
                    AppConstants.roleCenterHead,
                    AppConstants.roleSocialHead,
                    AppConstants.roleMedicalHead,
                    AppConstants.rolePsychHead,
                    AppConstants.roleRehabHead,
                    AppConstants.roleHomelifeHead,
                    AppConstants.roleSocialStaff,
                    AppConstants.roleMedicalStaff,
                    AppConstants.rolePsychStaff,
                    AppConstants.roleRehabStaff,
                    AppConstants.roleHomelifeStaff,
                  ].map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(_formatRole(role)),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                      if (selectedRole.contains('social')) {
                        selectedUnit = AppConstants.unitSocial;
                      } else if (selectedRole.contains('medical')) {
                        selectedUnit = AppConstants.unitMedical;
                      } else if (selectedRole.contains('psych')) {
                        selectedUnit = AppConstants.unitPsych;
                      } else if (selectedRole.contains('rehab')) {
                        selectedUnit = AppConstants.unitRehab;
                      } else if (selectedRole.contains('homelife')) {
                        selectedUnit = AppConstants.unitHomelife;
                      } else {
                        selectedUnit = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedRole != AppConstants.roleSuperAdmin &&
                    selectedRole != AppConstants.roleCenterHead)
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      prefixIcon: Icon(Icons.group_work),
                    ),
                    items: [
                      AppConstants.unitSocial,
                      AppConstants.unitMedical,
                      AppConstants.unitPsych,
                      AppConstants.unitRehab,
                      AppConstants.unitHomelife,
                    ].map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit.toUpperCase()),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedUnit = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isCreating ? null : () async {
                if (emailController.text.isEmpty ||
                    fullNameController.text.isEmpty ||
                    workIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                setDialogState(() => isCreating = true);

                try {
                  final result = await _adminRepo.provisionUser(
                    email: emailController.text.trim(),
                    fullName: fullNameController.text.trim(),
                    workId: workIdController.text.trim(),
                    role: selectedRole,
                    unit: selectedUnit,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _loadUsers();
                    // Show dialog with credentials
                    _showCredentialsDialog(
                      email: emailController.text.trim(),
                      fullName: fullNameController.text.trim(),
                      tempPassword: result.tempPassword,
                    );
                  }
                } catch (e) {
                  setDialogState(() => isCreating = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: isCreating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCredentialsDialog({
    required String email,
    required String fullName,
    required String tempPassword,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('User Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$fullName has been created successfully.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Share these credentials with the user:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Email: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(child: SelectableText(email)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Password: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: SelectableText(
                          tempPassword,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The user should change their password after first login.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _UserCard(
                    user: user,
                    onToggleActive: () async {
                      try {
                        if (user.isActive) {
                          await _adminRepo.deactivateUser(user.id);
                        } else {
                          await _adminRepo.reactivateUser(user.id);
                        }
                        _loadUsers();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggleActive;

  const _UserCard({
    required this.user,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isActive
                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                      : AppColors.dividerLight,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user.isActive
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: user.isActive
                                  ? null
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  'ID: ${user.workId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.work, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _formatRole(user.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ),
              ],
            ),
            if (user.unit != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.group_work, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(
                    'Unit: ${user.unit!.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 18,
                  ),
                  label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  style: TextButton.styleFrom(
                    foregroundColor: user.isActive
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
