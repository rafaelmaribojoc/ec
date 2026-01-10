import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/moca_assessment_bloc.dart';
import '../constants/moca_constants.dart';
import '../constants/moca_colors.dart';
import '../widgets/section_header.dart';

class AttentionScreen extends StatefulWidget {
  const AttentionScreen({super.key});

  @override
  State<AttentionScreen> createState() => _AttentionScreenState();
}

class _AttentionScreenState extends State<AttentionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _digitForwardCorrect = false;
  bool _digitBackwardCorrect = false;
  bool _vigilanceCorrect = false;
  int _serial7Score = 0;

  final List<bool> _serial7Answers = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get totalScore {
    int score = 0;
    if (_digitForwardCorrect) score++;
    if (_digitBackwardCorrect) score++;
    if (_vigilanceCorrect) score++;
    // Serial 7s: 3 points for 4-5 correct, 2 for 2-3, 1 for 1
    int correct = _serial7Answers.where((a) => a).length;
    if (correct >= 4) {
      score += 3;
    } else if (correct >= 2) {
      score += 2;
    } else if (correct >= 1) {
      score += 1;
    }
    _serial7Score =
        correct >= 4 ? 3 : (correct >= 2 ? 2 : (correct >= 1 ? 1 : 0));
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SectionHeader(
            title: 'Attention',
            subtitle: 'Digit span, vigilance, and serial 7s',
            currentSection: 4,
            totalSections: 8,
            color: MocaColors.attentionColor,
          ),
          TabBar(
            controller: _tabController,
            labelColor: MocaColors.attentionColor,
            unselectedLabelColor: MocaColors.textSecondary,
            indicatorColor: MocaColors.attentionColor,
            tabs: const [
              Tab(text: 'Digits'),
              Tab(text: 'Vigilance'),
              Tab(text: 'Serial 7s'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDigitSpan(),
                _buildVigilance(),
                _buildSerial7s(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDigitSpan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forward Digit Span (1 point)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
              'Read digits at 1 per second. Subject repeats in forward order.'),
          const SizedBox(height: 16),
          Card(
            color: MocaColors.attentionColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: MocaConstants.digitSpanForward
                    .map((d) => _buildDigitCircle(d.toString()))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildScoreToggle(
            'Repeated correctly: 2-1-8-5-4',
            _digitForwardCorrect,
            (value) => setState(() => _digitForwardCorrect = value),
          ),
          const Divider(height: 40),
          Text(
            'Backward Digit Span (1 point)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Subject repeats digits in BACKWARD order.'),
          const SizedBox(height: 16),
          Card(
            color: MocaColors.attentionColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: MocaConstants.digitSpanBackward
                        .map((d) => _buildDigitCircle(d.toString()))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Correct answer: ${MocaConstants.digitSpanBackward.reversed.join('-')}',
                    style: TextStyle(
                      color: MocaColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildScoreToggle(
            'Repeated correctly backward: 2-4-7',
            _digitBackwardCorrect,
            (value) => setState(() => _digitBackwardCorrect = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitCircle(String digit) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: MocaColors.attentionColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVigilance() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vigilance Task (1 point)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Read the letter sequence. Subject taps hand each time they hear the letter "A".',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children:
                        MocaConstants.vigilanceLetters.split('').map((letter) {
                      final isTarget = letter == 'A';
                      return Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isTarget
                              ? MocaColors.attentionColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isTarget
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isTarget
                                  ? MocaColors.attentionColor
                                  : MocaColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: MocaColors.infoLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: MocaColors.info),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Subject should tap 11 times (one for each "A"). Score 1 point if ≤2 errors.',
                      style: TextStyle(color: MocaColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreToggle(
            'Completed with ≤2 errors',
            _vigilanceCorrect,
            (value) => setState(() => _vigilanceCorrect = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSerial7s() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serial 7 Subtraction (3 points)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Starting from 100, subtract 7 repeatedly: 100, 93, 86, 79, 72, 65',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...MocaConstants.serial7Answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final answer = entry.value;
                    final previous = index == 0
                        ? 100
                        : MocaConstants.serial7Answers[index - 1];
                    return CheckboxListTile(
                      value: _serial7Answers[index],
                      onChanged: (value) {
                        setState(() => _serial7Answers[index] = value ?? false);
                      },
                      title: Text('$previous - 7 = $answer'),
                      activeColor: MocaColors.attentionColor,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: MocaColors.infoLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scoring:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: MocaColors.info),
                  ),
                  const SizedBox(height: 8),
                  const Text('• 4-5 correct = 3 points',
                      style: TextStyle(color: MocaColors.info)),
                  const Text('• 2-3 correct = 2 points',
                      style: TextStyle(color: MocaColors.info)),
                  const Text('• 1 correct = 1 point',
                      style: TextStyle(color: MocaColors.info)),
                  const Text('• 0 correct = 0 points',
                      style: TextStyle(color: MocaColors.info)),
                ],
              ),
            ),
          ),
        ],
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
                  color: MocaColors.attentionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: $totalScore/6',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MocaColors.attentionColor,
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
                        section: 'attention',
                        score: totalScore,
                        maxScore: 6,
                        details: {
                          'digit_forward': _digitForwardCorrect,
                          'digit_backward': _digitBackwardCorrect,
                          'vigilance': _vigilanceCorrect,
                          'serial7': _serial7Score,
                        },
                      ),
                    );
                context.read<MocaAssessmentBloc>().add(MocaNextSection());
                context.push('/moca/language');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MocaColors.attentionColor,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
