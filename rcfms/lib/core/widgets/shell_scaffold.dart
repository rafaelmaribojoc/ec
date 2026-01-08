import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

/// Navigation item model
class NavItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
  final List<NavItem>? children;

  const NavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.route,
    this.children,
  });
}

/// Default navigation items
const _defaultNavItems = [
  NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, route: '/dashboard'),
  NavItem(label: 'Scan', icon: Icons.nfc_outlined, selectedIcon: Icons.nfc, route: '/scan'),
  NavItem(label: 'Residents', icon: Icons.people_outline, selectedIcon: Icons.people, route: '/residents'),
  NavItem(label: 'Forms', icon: Icons.description_outlined, selectedIcon: Icons.description, route: '/forms'),
  NavItem(label: 'Approvals', icon: Icons.approval_outlined, selectedIcon: Icons.approval, route: '/approvals'),
  NavItem(label: 'Admin', icon: Icons.admin_panel_settings_outlined, selectedIcon: Icons.admin_panel_settings, route: '/admin'),
  NavItem(label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings, route: '/settings'),
];

/// Responsive shell scaffold with adaptive navigation
class ShellScaffold extends StatefulWidget {
  final Widget child;
  final String? title;
  final List<NavItem>? navItems;
  final int? selectedIndex;
  final void Function(int)? onNavItemTap;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? bottom;

  const ShellScaffold({
    super.key,
    required this.child,
    this.title,
    this.navItems,
    this.selectedIndex,
    this.onNavItemTap,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottom,
  });

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  bool _isRailExtended = false;
  int _selectedIndex = 0;

  List<NavItem> get _navItems => widget.navItems ?? _defaultNavItems;
  int get _currentIndex => widget.selectedIndex ?? _selectedIndex;

  void _handleNavTap(int index) {
    if (widget.onNavItemTap != null) {
      widget.onNavItemTap!(index);
    } else {
      setState(() => _selectedIndex = index);
      // Navigate using GoRouter
      final route = _navItems[index].route;
      GoRouter.of(context).go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        if (screen.isMobile) {
          return _buildMobileLayout(context, screen);
        } else if (screen.isTablet) {
          return _buildTabletLayout(context, screen);
        } else {
          return _buildDesktopLayout(context, screen);
        }
      },
    );
  }

  // Mobile: Drawer navigation
  Widget _buildMobileLayout(BuildContext context, ScreenInfo screen) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'RCFMS'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: widget.actions,
        bottom: widget.bottom,
      ),
      drawer: _buildDrawer(context),
      body: widget.child,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: _navItems.length <= 5
          ? _buildBottomNav(context)
          : null,
    );
  }

  // Tablet: Navigation Rail
  Widget _buildTabletLayout(BuildContext context, ScreenInfo screen) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'RCFMS'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: widget.actions,
        bottom: widget.bottom,
        leading: IconButton(
          icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
          onPressed: () => setState(() => _isRailExtended = !_isRailExtended),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: _isRailExtended,
            minWidth: 56,
            minExtendedWidth: 200,
            backgroundColor: AppColors.surface,
            selectedIndex: _currentIndex,
            onDestinationSelected: _handleNavTap,
            labelType: _isRailExtended 
                ? NavigationRailLabelType.none 
                : NavigationRailLabelType.all,
            leading: _isRailExtended
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildLogo(compact: true),
                  )
                : null,
            destinations: _navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  // Desktop: Sidebar navigation
  Widget _buildDesktopLayout(BuildContext context, ScreenInfo screen) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRailExtended ? 280 : 72,
            child: _buildSidebar(context, screen),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(context, screen),
                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 8),
                const Text(
                  'Resident Care & Facility\nManagement System',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == _currentIndex;
                return _buildDrawerItem(context, item, isSelected, index);
              },
            ),
          ),
          // Footer
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement sign out
            },
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    NavItem item,
    bool isSelected,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
          color: isSelected ? AppColors.primary : null,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.pop(context);
          _handleNavTap(index);
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _handleNavTap,
      destinations: _navItems.take(5).map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildSidebar(BuildContext context, ScreenInfo screen) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            padding: EdgeInsets.all(_isRailExtended ? 20 : 12),
            child: _isRailExtended
                ? _buildLogo()
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => setState(() => _isRailExtended = true),
                  ),
          ),
          if (_isRailExtended)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () => setState(() => _isRailExtended = false),
                    tooltip: 'Collapse',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: _isRailExtended ? 12 : 8,
                vertical: 4,
              ),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == _currentIndex;
                return _buildSidebarItem(item, isSelected, index);
              },
            ),
          ),
          // Collapse/expand toggle at bottom
          if (!_isRailExtended)
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _isRailExtended = true),
                tooltip: 'Expand',
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(NavItem item, bool isSelected, int index) {
    if (_isRailExtended) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: ListTile(
          leading: Icon(
            isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          dense: true,
          onTap: () => _handleNavTap(index),
        ),
      );
    }

    // Collapsed state - icon only
    return Tooltip(
      message: item.label,
      preferBelow: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: IconButton(
          icon: Icon(
            isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          onPressed: () => _handleNavTap(index),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ScreenInfo screen) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          const Spacer(),
          if (widget.actions != null) ...widget.actions!,
          const SizedBox(width: 16),
          // User menu
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                  dense: true,
                ),
              ),
            ],
            onSelected: (value) {
              // TODO: Handle menu selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 36 : 44,
          height: compact ? 36 : 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.elderly,
            color: AppColors.primary,
            size: compact ? 24 : 28,
          ),
        ),
        if (!compact || _isRailExtended) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RCFMS',
                style: TextStyle(
                  color: compact ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 18 : 20,
                ),
              ),
              Text(
                'Home for the Aged',
                style: TextStyle(
                  color: compact ? AppColors.textSecondary : Colors.white70,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Simple page scaffold with responsive padding
class PageScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool scrollable;
  final EdgeInsets? padding;

  const PageScaffold({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.scrollable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        final effectivePadding = padding ?? EdgeInsets.all(screen.horizontalPadding);
        
        Widget content = Padding(
          padding: effectivePadding,
          child: child,
        );

        if (scrollable) {
          content = SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: content,
          );
        }

        // On desktop within shell, no additional scaffold needed
        if (screen.isDesktop) {
          return content;
        }

        return content;
      },
    );
  }
}

/// Responsive card container
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenInfo.of(context);
    
    return Card(
      margin: margin ?? EdgeInsets.only(
        bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
      ),
      elevation: elevation ?? screen.value(mobile: 1.0, tablet: 2.0, desktop: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          screen.value(mobile: 8.0, tablet: 10.0, desktop: 12.0),
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(
          screen.value(mobile: 12.0, tablet: 16.0, desktop: 20.0),
        ),
        child: child,
      ),
    );
  }
}
