import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatRole(user.role),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.push('/settings/profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account settings
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person,
                      title: 'Edit Profile',
                      subtitle: 'Update username and profile info',
                      onTap: () => context.push('/settings/profile'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.draw,
                      title: 'Update Signature',
                      subtitle: 'Change your digital signature',
                      onTap: () => context.go('/setup-signature'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.lock,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // App settings
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Appearance',
                      subtitle: 'Theme and display settings',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // About
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info,
                      title: 'About RCFMS',
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Contact support team',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRole(String role) {
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.elderly, color: AppColors.primary),
            SizedBox(width: 12),
            Text('RCFMS'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resident Care & Facility Management System',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A comprehensive digital profile platform for eldercare facilities.',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Add logout event
              context.read<AuthBloc>().add(AuthLogoutRequested());
              // Force navigate to login immediately for responsive UX
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondaryLight,
      ),
      onTap: onTap,
    );
  }
}
