import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/models/ward_model.dart';
import '../../../data/repositories/resident_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../moca/bloc/moca_assessment_bloc.dart';
import '../../moca/constants/moca_colors.dart';

class NFCScanScreen extends StatefulWidget {
  const NFCScanScreen({super.key});

  @override
  State<NFCScanScreen> createState() => _NFCScanScreenState();
}

class _NFCScanScreenState extends State<NFCScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isNfcAvailable = false;
  bool _isScanning = false;
  WardModel? _scannedWard;
  List<ResidentModel> _residents = [];
  String? _error;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopNfcSession();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      setState(() {
        _isNfcAvailable = isAvailable;
      });
      if (isAvailable) {
        _startNfcSession();
      }
    } catch (e) {
      setState(() {
        _isNfcAvailable = false;
      });
    }
  }

  Future<void> _startNfcSession() async {
    if (!_isNfcAvailable) return;

    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            // Get NFC tag ID from the tag data
            final tagData = tag.data as Map<String, dynamic>;
            List<int>? nfcTagId;

            // Try to get identifier from different tag types
            if (tagData.containsKey('nfca')) {
              final nfca = tagData['nfca'] as Map<String, dynamic>?;
              nfcTagId = (nfca?['identifier'] as List?)?.cast<int>();
            } else if (tagData.containsKey('nfcb')) {
              final nfcb = tagData['nfcb'] as Map<String, dynamic>?;
              nfcTagId = (nfcb?['identifier'] as List?)?.cast<int>();
            } else if (tagData.containsKey('nfcf')) {
              final nfcf = tagData['nfcf'] as Map<String, dynamic>?;
              nfcTagId = (nfcf?['identifier'] as List?)?.cast<int>();
            } else if (tagData.containsKey('nfcv')) {
              final nfcv = tagData['nfcv'] as Map<String, dynamic>?;
              nfcTagId = (nfcv?['identifier'] as List?)?.cast<int>();
            } else if (tagData.containsKey('mifareclassic')) {
              final mifare = tagData['mifareclassic'] as Map<String, dynamic>?;
              nfcTagId = (mifare?['identifier'] as List?)?.cast<int>();
            } else if (tagData.containsKey('mifareultralight')) {
              final mifareUl =
                  tagData['mifareultralight'] as Map<String, dynamic>?;
              nfcTagId = (mifareUl?['identifier'] as List?)?.cast<int>();
            }

            if (nfcTagId == null || nfcTagId.isEmpty) {
              throw Exception('Could not read NFC tag');
            }

            final tagIdHex = nfcTagId
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();

            // Look up ward by NFC tag
            final residentRepo = context.read<ResidentRepository>();
            final ward = await residentRepo.getWardByNfcTag(tagIdHex);

            if (ward == null) {
              setState(() {
                _error = 'Ward not found for this NFC tag';
                _scannedWard = null;
                _residents = [];
              });
              return;
            }

            // Get residents in ward
            final residents = await residentRepo.getResidentsByWardId(ward.id);

            setState(() {
              _scannedWard = ward;
              _residents = residents;
              _error = null;
            });
          } catch (e) {
            setState(() {
              _error = e.toString();
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _stopNfcSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      // Ignore
    }
  }

  void _resetScan() {
    setState(() {
      _scannedWard = null;
      _residents = [];
      _error = null;
    });
    _startNfcSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Scan Ward'),
        actions: [
          if (_scannedWard != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetScan,
              tooltip: 'Scan Again',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isNfcAvailable) {
      return _buildNfcUnavailable();
    }

    if (_scannedWard != null) {
      return _buildResidentsList();
    }

    return _buildScanView();
  }

  Widget _buildNfcUnavailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nfc,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'NFC Not Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'This device does not support NFC or NFC is disabled. '
              'Please enable NFC in your device settings or use a different device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/residents'),
              child: const Text('Browse Residents Instead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated NFC icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.nfc,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to Scan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hold your device near the Ward NFC tag\nto view residents in that ward',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.go('/residents'),
              icon: const Icon(Icons.search),
              label: const Text('Browse Residents'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentsList() {
    return Column(
      children: [
        // Ward header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.room,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scannedWard!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_residents.length} residents',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _resetScan,
                ),
              ],
            ),
          ),
        ),
        // Residents list
        Expanded(
          child: _residents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color:
                            AppColors.textSecondaryLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No residents in this ward',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _residents.length,
                  itemBuilder: (context, index) {
                    final resident = _residents[index];
                    return _ResidentTile(
                      resident: resident,
                      onTap: () => context.push('/residents/${resident.id}'),
                      onNewForm: () => _showFormOptions(context, resident),
                      onNewAssessment: () =>
                          _startMocaAssessment(context, resident),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showFormOptions(BuildContext context, ResidentModel resident) {
    context.push('/residents/${resident.id}');
  }

  /// Start MoCA-P assessment with auto-filled resident data
  void _startMocaAssessment(BuildContext context, ResidentModel resident) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    // Default education years to 0 (will trigger adjustment if < 12 years)
    const educationYears = 0;

    // Start assessment with resident data auto-filled
    context.read<MocaAssessmentBloc>().add(
          MocaStartAssessment(
            residentId: resident.id,
            clinicianId: user?.id,
            residentName: resident.fullName,
            residentSex: resident.gender,
            residentBirthday: resident.dateOfBirth,
            educationYears: educationYears,
            educationAdjustment: educationYears < 12,
          ),
        );

    // Navigate to MoCA assessment
    // Use push() to allow back navigation
    context.push('/moca');
  }
}

class _ResidentTile extends StatelessWidget {
  final ResidentModel resident;
  final VoidCallback onTap;
  final VoidCallback? onNewForm;
  final VoidCallback? onNewAssessment;

  const _ResidentTile({
    required this.resident,
    required this.onTap,
    this.onNewForm,
    this.onNewAssessment,
  });

  @override
  Widget build(BuildContext context) {
    // Check if user is from psych unit
    final authState = context.read<AuthBloc>().state;
    final userUnit =
        authState is AuthAuthenticated ? authState.user.unit : null;
    final isPsychUnit = userUnit == 'psych';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        AppColors.primaryLight.withValues(alpha: 0.2),
                    child: Text(
                      resident.firstName[0] + resident.lastName[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resident.fullName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.cake,
                              size: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${resident.age} years',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (resident.roomNumber != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.meeting_room,
                                size: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Room ${resident.roomNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
              // Quick action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNewForm,
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text('New Form'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (isPsychUnit) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onNewAssessment,
                        icon: const Icon(Icons.psychology, size: 16),
                        label: const Text('Assessment'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MocaColors.primary,
                          side: BorderSide(
                              color: MocaColors.primary.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
