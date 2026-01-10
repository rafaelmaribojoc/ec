import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/repositories/resident_repository.dart';

class ResidentsListScreen extends StatefulWidget {
  const ResidentsListScreen({super.key});

  @override
  State<ResidentsListScreen> createState() => _ResidentsListScreenState();
}

class _ResidentsListScreenState extends State<ResidentsListScreen> {
  final ResidentRepository _residentRepo = ResidentRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ResidentModel> _residents = [];
  bool _isLoading = true;
  String? _error;
  String _selectedWard = 'All';

  final List<String> _wards = ['All', 'Ward A', 'Ward B', 'Ward C', 'Ward D'];

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final residents = await _residentRepo.getResidents();
      setState(() {
        _residents = residents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ResidentModel> get _filteredResidents {
    return _residents.where((r) {
      final matchesSearch = _searchController.text.isEmpty ||
          r.fullName.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesWard =
          _selectedWard == 'All' || r.currentWardId == _selectedWard;
      return matchesSearch && matchesWard;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Residents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search residents...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Ward filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _wards.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final ward = _wards[index];
                      final isSelected = ward == _selectedWard;

                      return FilterChip(
                        label: Text(ward),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedWard = ward);
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primarySurface,
                        checkmarkColor: AppColors.primary,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 1),

          // Results count
          Container(
            color: AppColors.surfaceHover,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${_filteredResidents.length} resident${_filteredResidents.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  'Sort by name',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          // Residents list
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/residents/add'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Resident'),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredResidents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadResidents,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredResidents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final resident = _filteredResidents[index];
          return _ResidentCard(
            resident: resident,
            onTap: () => context.push('/residents/${resident.id}'),
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
            'No residents found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
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
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadResidents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
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
                  Text(
                    'Filter Residents',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ward',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wards.map((ward) {
                      final isSelected = ward == _selectedWard;
                      return ChoiceChip(
                        label: Text(ward),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedWard = ward);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  final ResidentModel resident;
  final VoidCallback onTap;

  const _ResidentCard({
    required this.resident,
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
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    _getInitials(resident.fullName),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resident.fullName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resident.residentCode,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resident.currentWardId ?? 'No ward',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status badge
              _StatusBadge(status: resident.status),
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = _getStatusStyle(status);

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

  (Color, Color, String) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return (
          AppColors.success,
          AppColors.successSurface,
          'Active',
        );
      case 'discharged':
        return (
          AppColors.textSecondary,
          AppColors.surfaceHover,
          'Discharged',
        );
      case 'on_pass':
        return (
          AppColors.warning,
          AppColors.warningSurface,
          'On Pass',
        );
      default:
        return (
          AppColors.textSecondary,
          AppColors.surfaceHover,
          status,
        );
    }
  }
}
