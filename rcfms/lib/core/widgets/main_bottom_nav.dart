import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';

/// Main bottom navigation bar used across all main screens
class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userRole = state is AuthAuthenticated ? state.user.role : null;
        final isAdmin = userRole == 'super_admin' || userRole == 'center_head';
        final screenWidth = MediaQuery.of(context).size.width;
        final isCompact = screenWidth < 360;

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: AppColors.surface,
          elevation: 8,
          height: isCompact ? 60 : 68,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                isCompact: isCompact,
                onTap: () => context.go('/dashboard'),
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people_rounded,
                label: 'Residents',
                isSelected: currentIndex == 1,
                isCompact: isCompact,
                onTap: () => context.go('/residents'),
              ),
              // Center spacer for FAB
              SizedBox(width: isCompact ? 40 : 56),
              _NavItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description_rounded,
                label: 'Forms',
                isSelected: currentIndex == 2,
                isCompact: isCompact,
                onTap: () => context.go('/forms'),
              ),
              if (isAdmin)
                _NavItem(
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings_rounded,
                  label: 'Admin',
                  isSelected: currentIndex == 3,
                  isCompact: isCompact,
                  onTap: () => context.go('/admin'),
                )
              else
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'More',
                  isSelected: currentIndex == 3,
                  isCompact: isCompact,
                  onTap: () => context.go('/settings'),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Floating action button for NFC scan
class MainScanFab extends StatelessWidget {
  const MainScanFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/scan'),
      backgroundColor: AppColors.primary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.nfc_rounded, color: Colors.white, size: 28),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.isCompact = false,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      setState(() => _isPressed = false);
    });
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isCompact ? 22.0 : 24.0;
    final fontSize = widget.isCompact ? 9.0 : 11.0;
    final containerSize = widget.isCompact ? 38.0 : 44.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : _isPressed
                        ? AppColors.textSecondary.withValues(alpha: 0.08)
                        : Colors.transparent,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    key: ValueKey(widget.isSelected),
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: iconSize,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
