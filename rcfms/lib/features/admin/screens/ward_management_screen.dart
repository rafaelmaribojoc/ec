import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/ward_model.dart';
import '../../../data/repositories/admin_repository.dart';

class WardManagementScreen extends StatefulWidget {
  const WardManagementScreen({super.key});

  @override
  State<WardManagementScreen> createState() => _WardManagementScreenState();
}

class _WardManagementScreenState extends State<WardManagementScreen> {
  final _adminRepo = AdminRepository();
  List<WardModel> _wards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWards();
  }

  Future<void> _loadWards() async {
    setState(() => _isLoading = true);
    try {
      final wards = await _adminRepo.getAllWards();
      setState(() {
        _wards = wards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddWardDialog([WardModel? ward]) {
    final nameController = TextEditingController(text: ward?.name);
    final descriptionController = TextEditingController(text: ward?.description);
    final capacityController = TextEditingController(
      text: ward?.capacity.toString() ?? '10',
    );
    final floorController = TextEditingController(text: ward?.floor);
    final buildingController = TextEditingController(text: ward?.building);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ward == null ? 'Add New Ward' : 'Edit Ward'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ward Name *',
                  prefixIcon: Icon(Icons.room),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: floorController,
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        prefixIcon: Icon(Icons.layers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: buildingController,
                      decoration: const InputDecoration(
                        labelText: 'Building',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ward name is required'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              try {
                if (ward == null) {
                  await _adminRepo.createWard(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    capacity: int.tryParse(capacityController.text) ?? 10,
                    floor: floorController.text.trim().isEmpty
                        ? null
                        : floorController.text.trim(),
                    building: buildingController.text.trim().isEmpty
                        ? null
                        : buildingController.text.trim(),
                  );
                } else {
                  await _adminRepo.updateWard(
                    id: ward.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    capacity: int.tryParse(capacityController.text),
                    floor: floorController.text.trim(),
                    building: buildingController.text.trim(),
                  );
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ward == null ? 'Ward created' : 'Ward updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadWards();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(ward == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showAssignNfcDialog(WardModel ward) {
    final nfcController = TextEditingController(text: ward.nfcTagId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign NFC Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign an NFC tag to ${ward.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nfcController,
              decoration: const InputDecoration(
                labelText: 'NFC Tag ID',
                prefixIcon: Icon(Icons.nfc),
                hintText: 'e.g., AA:BB:CC:DD',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Scan a tag on a device to get its ID',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
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
            onPressed: () async {
              try {
                await _adminRepo.assignNfcTag(
                  wardId: ward.id,
                  nfcTagId: nfcController.text.trim().toUpperCase(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('NFC tag assigned'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadWards();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ward Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWards,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _wards.length,
                itemBuilder: (context, index) {
                  final ward = _wards[index];
                  return _WardCard(
                    ward: ward,
                    onEdit: () => _showAddWardDialog(ward),
                    onAssignNfc: () => _showAssignNfcDialog(ward),
                    onDelete: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Ward'),
                          content: Text('Are you sure you want to delete ${ward.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await _adminRepo.deleteWard(ward.id);
                          _loadWards();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWardDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Ward'),
      ),
    );
  }
}

class _WardCard extends StatelessWidget {
  final WardModel ward;
  final VoidCallback onEdit;
  final VoidCallback onAssignNfc;
  final VoidCallback onDelete;

  const _WardCard({
    required this.ward,
    required this.onEdit,
    required this.onAssignNfc,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.room, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ward.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (ward.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              ward.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ward.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ward.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: ward.isActive ? AppColors.success : AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.people,
                      label: '${ward.currentOccupancy}/${ward.capacity}',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.nfc,
                      label: ward.hasNfcTag ? 'NFC Assigned' : 'No NFC',
                      color: ward.hasNfcTag ? AppColors.success : AppColors.warning,
                    ),
                    if (ward.floor != null) ...[
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.layers,
                        label: 'Floor ${ward.floor}',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAssignNfc,
                  icon: const Icon(Icons.nfc, size: 18),
                  label: const Text('NFC'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
