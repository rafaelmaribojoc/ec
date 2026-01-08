import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Navigation item model
class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
  });
}

/// Shell scaffold with responsive navigation
class ShellScaffold extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final int selectedIndex;
  final Function(int)? onNavItemTap;

  const ShellScaffold({
    super.key,
    required this.child,
    this.navItems = const [],
    this.selectedIndex = 0,
    this.onNavItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    if (navItems.isEmpty) {
      return child;
    }

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else if (isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(context, expanded: true),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(context, expanded: false),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool expanded}) {
    return Container(
      width: expanded ? 260 : 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 20 : 16,
                vertical: 24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.elderly,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    Text(
                      'RCFMS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == selectedIndex;

                  return _SidebarItem(
                    item: item,
                    isSelected: isSelected,
                    expanded: expanded,
                    onTap: () => onNavItemTap?.call(index),
                  );
                }).toList(),
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(expanded ? 16 : 12),
              child: _SidebarItem(
                item: const NavItem(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  route: '/settings',
                ),
                isSelected: false,
                expanded: expanded,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;

              return _BottomNavItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onNavItemTap?.call(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 12 : 8,
        vertical: 2,
      ),
      child: Material(
        color: isSelected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 16 : 12,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
