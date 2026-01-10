import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/resident_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/moca_assessment_bloc.dart';
import '../constants/moca_colors.dart';

class MocaHomeScreen extends StatelessWidget {
  final String? residentId;
  final ResidentModel? resident;

  const MocaHomeScreen({
    super.key,
    this.residentId,
    this.resident,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  if (user != null)
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: MocaColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: MocaColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'MoCA Assessment',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Montreal Cognitive Assessment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: MocaColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      // Resident info if available
                      if (resident != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MocaColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  color: MocaColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Resident',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: MocaColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${resident!.firstName} ${resident!.lastName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MocaColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'About the MoCA Test',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.timer_outlined,
                                '10-15 minutes',
                                'Estimated duration',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.format_list_numbered,
                                '8 sections',
                                'Cognitive domains tested',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.score_outlined,
                                '30 points',
                                'Maximum score (≥26 normal)',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sections Overview
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assessment Sections',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSectionItem('1. Visuospatial/Executive',
                                  '5 pts', MocaColors.visuospatialColor),
                              _buildSectionItem(
                                  '2. Naming', '3 pts', MocaColors.namingColor),
                              _buildSectionItem('3. Memory', 'No pts',
                                  MocaColors.memoryColor),
                              _buildSectionItem('4. Attention', '6 pts',
                                  MocaColors.attentionColor),
                              _buildSectionItem('5. Language', '3 pts',
                                  MocaColors.languageColor),
                              _buildSectionItem('6. Abstraction', '2 pts',
                                  MocaColors.abstractionColor),
                              _buildSectionItem('7. Delayed Recall', '5 pts',
                                  MocaColors.recallColor),
                              _buildSectionItem('8. Orientation', '6 pts',
                                  MocaColors.orientationColor),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Start button
              ElevatedButton(
                onPressed: () {
                  final clinicianId = user?.id;
                  context.read<MocaAssessmentBloc>().add(
                        MocaStartAssessment(
                          residentId: residentId,
                          clinicianId: clinicianId,
                          educationAdjustment: false,
                        ),
                      );
                  context.push('/moca/visuospatial');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MocaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: MocaColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: MocaColors.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: MocaColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionItem(String name, String points, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            points,
            style: TextStyle(
              color: MocaColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
