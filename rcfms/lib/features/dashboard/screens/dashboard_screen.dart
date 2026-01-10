import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../../auth/bloc/auth_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context, user?.fullName ?? 'User'),
                ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildQuickStats(context),
                  ),
                ),

                // Recent Activity
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildRecentActivity(context),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const MainBottomNav(currentIndex: 0),
          floatingActionButton: const MainScanFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                iconColor: AppColors.primary,
                label: 'Total Residents',
                value: '42',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.assignment_outlined,
                iconColor: AppColors.warning,
                label: 'Pending Forms',
                value: '8',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                label: 'Completed Today',
                value: '5',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.meeting_room_outlined,
                iconColor: AppColors.unitPsych,
                label: 'Active Wards',
                value: '4',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.assignment_turned_in,
                iconColor: AppColors.success,
                title: 'Progress Notes submitted',
                subtitle: 'Juan Dela Cruz • Social Service',
                time: '2 min ago',
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.person_add,
                iconColor: AppColors.primary,
                title: 'New resident admitted',
                subtitle: 'Maria Santos • Ward A',
                time: '1 hour ago',
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.assignment_return,
                iconColor: AppColors.warning,
                title: 'Form returned for revision',
                subtitle: 'Incident Report • Home Life',
                time: '3 hours ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
