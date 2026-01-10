import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/moca_assessment_bloc.dart';
import '../constants/moca_constants.dart';
import '../constants/moca_colors.dart';
import '../widgets/section_header.dart';

class DelayedRecallScreen extends StatefulWidget {
  const DelayedRecallScreen({super.key});

  @override
  State<DelayedRecallScreen> createState() => _DelayedRecallScreenState();
}

class _DelayedRecallScreenState extends State<DelayedRecallScreen> {
  final List<bool> _uncuedRecall = [false, false, false, false, false];
  final List<bool> _categoryRecall = [false, false, false, false, false];
  final List<bool> _multipleChoiceRecall = [false, false, false, false, false];

  final List<String> _categoryHints = [
    'body part',
    'fabric/material',
    'building',
    'flower',
    'color',
  ];

  int get totalScore => _uncuedRecall.where((r) => r).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SectionHeader(
            title: 'Delayed Recall',
            subtitle: 'Recall the words from earlier without cues',
            currentSection: 7,
            totalSections: 8,
            color: MocaColors.recallColor,
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
                              'Ask the subject to recall the words from the memory section. ONLY uncued (free) recall scores points.',
                              style: TextStyle(color: MocaColors.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Free Recall (5 points)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ask: "What were the 5 words I asked you to remember?"',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: MocaConstants.memoryWords
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final word = entry.value;
                          return _buildWordRow(index, word);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryExpansionTile(),
                  const SizedBox(height: 16),
                  _buildMultipleChoiceExpansionTile(),
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
                              'Only UNCUED recall is scored. Category cues and multiple choice are for clinical information only.',
                              style: TextStyle(color: Colors.orange[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildWordRow(int index, String word) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: index < 4 ? MocaColors.divider : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _uncuedRecall[index]
                  ? MocaColors.success
                  : MocaColors.recallColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: _uncuedRecall[index]
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MocaColors.recallColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              word,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _uncuedRecall[index]
                    ? MocaColors.success
                    : MocaColors.textPrimary,
                decoration:
                    _uncuedRecall[index] ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Switch(
            value: _uncuedRecall[index],
            onChanged: (value) {
              setState(() {
                _uncuedRecall[index] = value;
                if (value) {
                  _categoryRecall[index] = false;
                  _multipleChoiceRecall[index] = false;
                }
              });
            },
            activeColor: MocaColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryExpansionTile() {
    return Card(
      child: ExpansionTile(
        title: const Text('Category Cues (optional)'),
        subtitle: const Text('Use if word not recalled freely'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: MocaConstants.memoryWords.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final hint = _categoryHints[index];
                return CheckboxListTile(
                  value: _categoryRecall[index],
                  onChanged: _uncuedRecall[index]
                      ? null
                      : (value) => setState(
                          () => _categoryRecall[index] = value ?? false),
                  title: Text('$word (hint: $hint)'),
                  subtitle: Text('Category: $hint'),
                  activeColor: MocaColors.recallColor,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceExpansionTile() {
    return Card(
      child: ExpansionTile(
        title: const Text('Multiple Choice (optional)'),
        subtitle: const Text('Use if category cue fails'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: MocaConstants.memoryWords.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                return CheckboxListTile(
                  value: _multipleChoiceRecall[index],
                  onChanged: (_uncuedRecall[index] || _categoryRecall[index])
                      ? null
                      : (value) => setState(
                          () => _multipleChoiceRecall[index] = value ?? false),
                  title: Text(word),
                  activeColor: MocaColors.recallColor,
                );
              }).toList(),
            ),
          ),
        ],
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
                  color: MocaColors.recallColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: $totalScore/5 (uncued only)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MocaColors.recallColor,
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
                        section: 'delayedRecall',
                        score: totalScore,
                        maxScore: 5,
                        details: {
                          'uncued': _uncuedRecall,
                          'category': _categoryRecall,
                          'multiple_choice': _multipleChoiceRecall,
                        },
                      ),
                    );
                context.read<MocaAssessmentBloc>().add(MocaNextSection());
                context.push('/moca/orientation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MocaColors.recallColor,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
