import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../models/moca_assessment_model.dart';

// Events
abstract class MocaAssessmentEvent extends Equatable {
  const MocaAssessmentEvent();

  @override
  List<Object?> get props => [];
}

class MocaStartAssessment extends MocaAssessmentEvent {
  final String? residentId;
  final String? clinicianId;
  final bool educationAdjustment;
  final String? residentName;
  final String? residentSex;
  final DateTime? residentBirthday;
  final int educationYears;

  const MocaStartAssessment({
    this.residentId,
    this.clinicianId,
    this.educationAdjustment = false,
    this.residentName,
    this.residentSex,
    this.residentBirthday,
    this.educationYears = 0,
  });

  @override
  List<Object?> get props => [
        residentId,
        clinicianId,
        educationAdjustment,
        residentName,
        residentSex,
        residentBirthday,
        educationYears,
      ];
}

class MocaSaveSectionResult extends MocaAssessmentEvent {
  final String section;
  final int score;
  final int maxScore;
  final Map<String, dynamic>? details;

  const MocaSaveSectionResult({
    required this.section,
    required this.score,
    required this.maxScore,
    this.details,
  });

  @override
  List<Object?> get props => [section, score, maxScore, details];
}

class MocaNextSection extends MocaAssessmentEvent {}

class MocaPreviousSection extends MocaAssessmentEvent {}

class MocaSetMemoryWords extends MocaAssessmentEvent {
  final List<String> words;

  const MocaSetMemoryWords(this.words);

  @override
  List<Object?> get props => [words];
}

class MocaCompleteAssessment extends MocaAssessmentEvent {}

class MocaResetAssessment extends MocaAssessmentEvent {}

// States
class MocaAssessmentState extends Equatable {
  final bool isLoading;
  final String? error;
  final MocaAssessmentModel? assessment;
  final int currentSectionIndex;
  final List<String> memoryWordsRecalled;

  const MocaAssessmentState({
    this.isLoading = false,
    this.error,
    this.assessment,
    this.currentSectionIndex = 0,
    this.memoryWordsRecalled = const [],
  });

  static const List<String> sectionOrder = [
    'visuospatial',
    'naming',
    'memory',
    'attention',
    'language',
    'abstraction',
    'delayedRecall',
    'orientation',
  ];

  String get currentSection => sectionOrder[currentSectionIndex];
  bool get isLastSection => currentSectionIndex >= sectionOrder.length - 1;
  bool get isFirstSection => currentSectionIndex == 0;

  MocaAssessmentState copyWith({
    bool? isLoading,
    String? error,
    MocaAssessmentModel? assessment,
    int? currentSectionIndex,
    List<String>? memoryWordsRecalled,
  }) {
    return MocaAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      assessment: assessment ?? this.assessment,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      memoryWordsRecalled: memoryWordsRecalled ?? this.memoryWordsRecalled,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        assessment,
        currentSectionIndex,
        memoryWordsRecalled,
      ];
}

// BLoC
class MocaAssessmentBloc
    extends Bloc<MocaAssessmentEvent, MocaAssessmentState> {
  final _uuid = const Uuid();

  MocaAssessmentBloc() : super(const MocaAssessmentState()) {
    on<MocaStartAssessment>(_onStartAssessment);
    on<MocaSaveSectionResult>(_onSaveSectionResult);
    on<MocaNextSection>(_onNextSection);
    on<MocaPreviousSection>(_onPreviousSection);
    on<MocaSetMemoryWords>(_onSetMemoryWords);
    on<MocaCompleteAssessment>(_onCompleteAssessment);
    on<MocaResetAssessment>(_onResetAssessment);
  }

  void _onStartAssessment(
    MocaStartAssessment event,
    Emitter<MocaAssessmentState> emit,
  ) {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Determine education adjustment based on years of education
      // MoCA scoring: +1 point if education < 12 years
      final shouldAdjust = event.educationYears > 0 && event.educationYears < 12;
      
      final assessment = MocaAssessmentModel.empty(
        id: _uuid.v4(),
        clinicianId: event.clinicianId,
        residentId: event.residentId,
        educationAdjustment: event.educationAdjustment || shouldAdjust,
        residentName: event.residentName,
        residentSex: event.residentSex,
        residentBirthday: event.residentBirthday,
        educationYears: event.educationYears,
      );

      emit(state.copyWith(
        isLoading: false,
        assessment: assessment,
        currentSectionIndex: 0,
        memoryWordsRecalled: [],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onSaveSectionResult(
    MocaSaveSectionResult event,
    Emitter<MocaAssessmentState> emit,
  ) {
    if (state.assessment == null) return;

    final result = SectionResult(
      section: event.section,
      score: event.score,
      maxScore: event.maxScore,
      details: event.details ?? {},
      completedAt: DateTime.now(),
    );

    final updatedResults = Map<String, SectionResult>.from(
      state.assessment!.sectionResults,
    );
    updatedResults[event.section] = result;

    final totalScore = updatedResults.values.fold<int>(
      0,
      (sum, r) => sum + r.score,
    );

    final updatedAssessment = state.assessment!.copyWith(
      sectionResults: updatedResults,
      totalScore: totalScore,
    );

    emit(state.copyWith(assessment: updatedAssessment));
  }

  void _onNextSection(
    MocaNextSection event,
    Emitter<MocaAssessmentState> emit,
  ) {
    if (!state.isLastSection) {
      emit(state.copyWith(
        currentSectionIndex: state.currentSectionIndex + 1,
      ));
    }
  }

  void _onPreviousSection(
    MocaPreviousSection event,
    Emitter<MocaAssessmentState> emit,
  ) {
    if (!state.isFirstSection) {
      emit(state.copyWith(
        currentSectionIndex: state.currentSectionIndex - 1,
      ));
    }
  }

  void _onSetMemoryWords(
    MocaSetMemoryWords event,
    Emitter<MocaAssessmentState> emit,
  ) {
    emit(state.copyWith(memoryWordsRecalled: event.words));
  }

  void _onCompleteAssessment(
    MocaCompleteAssessment event,
    Emitter<MocaAssessmentState> emit,
  ) {
    if (state.assessment == null) return;

    final completedAssessment = state.assessment!.copyWith(
      completedAt: DateTime.now(),
    );

    emit(state.copyWith(assessment: completedAssessment));
  }

  void _onResetAssessment(
    MocaResetAssessment event,
    Emitter<MocaAssessmentState> emit,
  ) {
    emit(const MocaAssessmentState());
  }
}
