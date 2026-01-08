import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRoleDisplayName(user.role),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: Colors.white,
                    onPressed: () {
                      // TODO: Show notifications
                    },
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Actions
                    _buildSectionTitle(context, 'Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActions(context, user.role),
                    const SizedBox(height: 24),

                    // Stats Cards
                    _buildSectionTitle(context, 'Overview'),
                    const SizedBox(height: 12),
                    _buildStatsCards(context),
                    const SizedBox(height: 24),

                    // Recent Activity
                    _buildSectionTitle(context, 'Recent Activity'),
                    const SizedBox(height: 12),
                    _buildRecentActivity(context),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return 'Super Administrator';
      case AppConstants.roleCenterHead:
        return 'Center Head';
      case AppConstants.roleSocialHead:
        return 'Social Services Head';
      case AppConstants.roleMedicalHead:
        return 'Medical Unit Head';
      case AppConstants.rolePsychHead:
        return 'Psychology Head';
      case AppConstants.roleRehabHead:
        return 'Rehabilitation Head';
      case AppConstants.roleHomelifeHead:
        return 'Homelife Head';
      default:
        return role
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String role) {
    final actions = <_QuickAction>[];

    // Common actions
    actions.add(_QuickAction(
      icon: Icons.nfc,
      label: 'Scan Ward',
      color: AppColors.primary,
      onTap: () => context.go('/scan'),
    ));

    actions.add(_QuickAction(
      icon: Icons.people,
      label: 'Residents',
      color: AppColors.secondary,
      onTap: () => context.go('/residents'),
    ));

    // Role-specific actions
    if (role == AppConstants.roleSocialHead) {
      actions.add(_QuickAction(
        icon: Icons.person_add,
        label: 'Add Resident',
        color: AppColors.unitSocial,
        onTap: () => context.go('/residents/add'),
      ));
    }

    if (role.endsWith('_head') || role == AppConstants.roleCenterHead) {
      actions.add(_QuickAction(
        icon: Icons.approval,
        label: 'Approvals',
        color: AppColors.warning,
        onTap: () => context.go('/approvals'),
      ));
    }

    if (role.endsWith('_staff')) {
      actions.add(_QuickAction(
        icon: Icons.add_box,
        label: 'New Form',
        color: AppColors.accent,
        onTap: () => context.go('/forms'),
      ));
    }

    if (role == AppConstants.roleSuperAdmin) {
      actions.add(_QuickAction(
        icon: Icons.admin_panel_settings,
        label: 'Admin Panel',
        color: AppColors.primaryDark,
        onTap: () => context.go('/admin'),
      ));
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildQuickActionCard(context, action);
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, _QuickAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            label: 'Residents',
            value: '64',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.assignment,
            label: 'Pending',
            value: '8',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: '156',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // Placeholder for recent activity
    final activities = [
      _ActivityItem(
        icon: Icons.check_circle,
        title: 'Daily Vitals Approved',
        subtitle: 'John Doe • Ward A',
        time: '2 min ago',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: Icons.assignment,
        title: 'New Incident Report',
        subtitle: 'Jane Smith • Ward B',
        time: '15 min ago',
        color: AppColors.warning,
      ),
      _ActivityItem(
        icon: Icons.person_add,
        title: 'New Resident Added',
        subtitle: 'Robert Johnson • Ward C',
        time: '1 hour ago',
        color: AppColors.primary,
      ),
    ];

    return Column(
      children: activities
          .map((activity) => _buildActivityItem(context, activity))
          .toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context, _ActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}
