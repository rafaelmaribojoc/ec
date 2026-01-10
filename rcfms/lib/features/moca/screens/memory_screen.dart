import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/moca_assessment_bloc.dart';
import '../constants/moca_constants.dart';
import '../constants/moca_colors.dart';
import '../widgets/section_header.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  int _currentTrial = 1;
  final List<List<bool>> _trialResults = [
    [false, false, false, false, false],
    [false, false, false, false, false],
  ];
  bool _wordsShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SectionHeader(
            title: 'Memory',
            subtitle: 'Word list learning - 2 trials',
            currentSection: 3,
            totalSections: 8,
            color: MocaColors.memoryColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: MocaColors.infoLight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: MocaColors.info),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Read the words aloud to the patient at a rate of one word per second. They must repeat all words back. Do 2 trials.',
                              style: TextStyle(color: MocaColors.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Words to Remember',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (!_wordsShown)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _wordsShown = true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show Words'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MocaColors.memoryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    _buildWordsList(),
                  if (_wordsShown) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text(
                          'Trial $_currentTrial of 2',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        if (_currentTrial == 1)
                          TextButton(
                            onPressed: () => setState(() => _currentTrial = 2),
                            child: const Text('Go to Trial 2'),
                          ),
                        if (_currentTrial == 2)
                          TextButton(
                            onPressed: () => setState(() => _currentTrial = 1),
                            child: const Text('Back to Trial 1'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTrialChecklist(),
                    const SizedBox(height: 24),
                    Card(
                      color: MocaColors.warningLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: MocaColors.warning),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No points are awarded now. These words will be asked again in the Delayed Recall section.',
                                style: TextStyle(color: Colors.orange[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildWordsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: MocaConstants.memoryWords.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: index < 4 ? 12 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: MocaColors.memoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: MocaColors.memoryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    word,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MocaColors.memoryColor,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrialChecklist() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mark words recalled:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...MocaConstants.memoryWords.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              return CheckboxListTile(
                value: _trialResults[_currentTrial - 1][index],
                onChanged: (value) {
                  setState(() {
                    _trialResults[_currentTrial - 1][index] = value ?? false;
                  });
                },
                title: Text(word),
                activeColor: MocaColors.memoryColor,
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final trial1Count = _trialResults[0].where((r) => r).length;
    final trial2Count = _trialResults[1].where((r) => r).length;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MocaColors.memoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Trial 1: $trial1Count/5 | Trial 2: $trial2Count/5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MocaColors.memoryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No points - recall tested later',
                    style: TextStyle(
                      fontSize: 11,
                      color: MocaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Back'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Store words for delayed recall
                context.read<MocaAssessmentBloc>().add(
                      MocaSetMemoryWords(MocaConstants.memoryWords),
                    );
                context.read<MocaAssessmentBloc>().add(
                      MocaSaveSectionResult(
                        section: 'memory',
                        score: 0,
                        maxScore: 0,
                        details: {
                          'trial1': _trialResults[0],
                          'trial2': _trialResults[1],
                        },
                      ),
                    );
                context.read<MocaAssessmentBloc>().add(MocaNextSection());
                context.push('/moca/attention');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MocaColors.memoryColor,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
