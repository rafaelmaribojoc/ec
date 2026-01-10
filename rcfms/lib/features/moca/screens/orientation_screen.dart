import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/moca_assessment_bloc.dart';
import '../constants/moca_colors.dart';
import '../widgets/section_header.dart';

class OrientationScreen extends StatefulWidget {
  const OrientationScreen({super.key});

  @override
  State<OrientationScreen> createState() => _OrientationScreenState();
}

class _OrientationScreenState extends State<OrientationScreen> {
  bool _dateCorrect = false;
  bool _monthCorrect = false;
  bool _yearCorrect = false;
  bool _dayCorrect = false;
  bool _placeCorrect = false;
  bool _cityCorrect = false;

  int get totalScore {
    int score = 0;
    if (_dateCorrect) score++;
    if (_monthCorrect) score++;
    if (_yearCorrect) score++;
    if (_dayCorrect) score++;
    if (_placeCorrect) score++;
    if (_cityCorrect) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      body: Column(
        children: [
          SectionHeader(
            title: 'Orientation',
            subtitle: 'Assessment of time and place awareness',
            currentSection: 8,
            totalSections: 8,
            color: MocaColors.orientationColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current date reference
                  Card(
                    color: MocaColors.orientationColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: MocaColors.orientationColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today\'s Date (for reference)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: MocaColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEEE, MMMM d, yyyy').format(now),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: MocaColors.orientationColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Time Orientation (4 points)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  _buildOrientationItem(
                    label: 'Date',
                    hint: 'What is today\'s date?',
                    correctAnswer: now.day.toString(),
                    isCorrect: _dateCorrect,
                    onChanged: (v) => setState(() => _dateCorrect = v),
                  ),
                  _buildOrientationItem(
                    label: 'Month',
                    hint: 'What month is it?',
                    correctAnswer: DateFormat('MMMM').format(now),
                    isCorrect: _monthCorrect,
                    onChanged: (v) => setState(() => _monthCorrect = v),
                  ),
                  _buildOrientationItem(
                    label: 'Year',
                    hint: 'What year is it?',
                    correctAnswer: now.year.toString(),
                    isCorrect: _yearCorrect,
                    onChanged: (v) => setState(() => _yearCorrect = v),
                  ),
                  _buildOrientationItem(
                    label: 'Day of Week',
                    hint: 'What day of the week is it?',
                    correctAnswer: DateFormat('EEEE').format(now),
                    isCorrect: _dayCorrect,
                    onChanged: (v) => setState(() => _dayCorrect = v),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Place Orientation (2 points)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  _buildOrientationItem(
                    label: 'Place',
                    hint: 'Where are we now? (building/location)',
                    correctAnswer: 'Varies',
                    isCorrect: _placeCorrect,
                    onChanged: (v) => setState(() => _placeCorrect = v),
                  ),
                  _buildOrientationItem(
                    label: 'City',
                    hint: 'What city are we in?',
                    correctAnswer: 'Varies',
                    isCorrect: _cityCorrect,
                    onChanged: (v) => setState(() => _cityCorrect = v),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOrientationItem({
    required String label,
    required String hint,
    required String correctAnswer,
    required bool isCorrect,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: const TextStyle(
                            color: MocaColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (correctAnswer != 'Varies')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MocaColors.orientationColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      correctAnswer,
                      style: TextStyle(
                        color: MocaColors.orientationColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildScoreToggle('Answered correctly', isCorrect, onChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: value ? MocaColors.successLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(8),
          splashColor: (value ? MocaColors.success : MocaColors.primary)
              .withOpacity(0.1),
          highlightColor: (value ? MocaColors.success : MocaColors.primary)
              .withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value ? MocaColors.success : MocaColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.circle_outlined,
                  color: value ? MocaColors.success : MocaColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          value ? MocaColors.success : MocaColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MocaColors.orientationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: $totalScore/6',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MocaColors.orientationColor,
                  ),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Back'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                context.read<MocaAssessmentBloc>().add(
                      MocaSaveSectionResult(
                        section: 'orientation',
                        score: totalScore,
                        maxScore: 6,
                        details: {
                          'date': _dateCorrect,
                          'month': _monthCorrect,
                          'year': _yearCorrect,
                          'day': _dayCorrect,
                          'place': _placeCorrect,
                          'city': _cityCorrect,
                        },
                      ),
                    );
                context
                    .read<MocaAssessmentBloc>()
                    .add(MocaCompleteAssessment());
                context.push('/moca/complete');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MocaColors.orientationColor,
              ),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
