/// Assessment section enumeration
enum AssessmentSection {
  visuospatial,
  naming,
  memory,
  attention,
  language,
  abstraction,
  delayedRecall,
  orientation,
}

/// Assessment model for MoCA-P
class MocaAssessmentModel {
  final String id;
  final String? clinicianId;
  final String? residentId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalScore;
  final int maxScore;
  final bool educationAdjustment;
  final Map<String, SectionResult> sectionResults;
  final DateTime createdAt;

  const MocaAssessmentModel({
    required this.id,
    this.clinicianId,
    this.residentId,
    required this.startedAt,
    this.completedAt,
    required this.totalScore,
    this.maxScore = 30,
    required this.educationAdjustment,
    required this.sectionResults,
    required this.createdAt,
  });

  /// Create empty assessment
  factory MocaAssessmentModel.empty({
    required String id,
    String? clinicianId,
    String? residentId,
    bool educationAdjustment = false,
  }) {
    return MocaAssessmentModel(
      id: id,
      clinicianId: clinicianId,
      residentId: residentId,
      startedAt: DateTime.now(),
      totalScore: 0,
      educationAdjustment: educationAdjustment,
      sectionResults: {},
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory MocaAssessmentModel.fromJson(Map<String, dynamic> json) {
    final sectionResultsJson = json['section_results'] as Map<String, dynamic>?;
    final sectionResults = <String, SectionResult>{};

    if (sectionResultsJson != null) {
      sectionResultsJson.forEach((key, value) {
        sectionResults[key] = SectionResult.fromJson(value);
      });
    }

    return MocaAssessmentModel(
      id: json['id'] as String,
      clinicianId: json['clinician_id'] as String?,
      residentId: json['resident_id'] as String?,
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      totalScore: json['total_score'] as int,
      maxScore: json['max_score'] as int? ?? 30,
      educationAdjustment: json['education_adjustment'] as bool? ?? false,
      sectionResults: sectionResults,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final sectionResultsJson = <String, dynamic>{};
    sectionResults.forEach((key, value) {
      sectionResultsJson[key] = value.toJson();
    });

    return {
      'id': id,
      'clinician_id': clinicianId,
      'resident_id': residentId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'total_score': totalScore,
      'max_score': maxScore,
      'education_adjustment': educationAdjustment,
      'section_results': sectionResultsJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with
  MocaAssessmentModel copyWith({
    String? id,
    String? clinicianId,
    String? residentId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalScore,
    int? maxScore,
    bool? educationAdjustment,
    Map<String, SectionResult>? sectionResults,
    DateTime? createdAt,
  }) {
    return MocaAssessmentModel(
      id: id ?? this.id,
      clinicianId: clinicianId ?? this.clinicianId,
      residentId: residentId ?? this.residentId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      educationAdjustment: educationAdjustment ?? this.educationAdjustment,
      sectionResults: sectionResults ?? this.sectionResults,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get adjusted total score
  int get adjustedScore {
    if (educationAdjustment) {
      return totalScore + 1 > maxScore ? maxScore : totalScore + 1;
    }
    return totalScore;
  }

  /// Check if score is normal
  bool get isNormal => adjustedScore >= 26;

  /// Get completion status
  bool get isComplete => completedAt != null;

  /// Get duration
  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return null;
  }

  /// Get section result
  SectionResult? getSectionResult(AssessmentSection section) {
    return sectionResults[section.name];
  }

  @override
  String toString() {
    return 'MocaAssessmentModel(id: $id, totalScore: $totalScore, adjustedScore: $adjustedScore)';
  }
}

/// Section result model
class SectionResult {
  final String section;
  final int score;
  final int maxScore;
  final Map<String, dynamic> details;
  final DateTime completedAt;

  const SectionResult({
    required this.section,
    required this.score,
    required this.maxScore,
    required this.details,
    required this.completedAt,
  });

  /// Create from JSON
  factory SectionResult.fromJson(Map<String, dynamic> json) {
    return SectionResult(
      section: json['section'] as String,
      score: json['score'] as int,
      maxScore: json['max_score'] as int,
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      completedAt: DateTime.parse(json['completed_at']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'score': score,
      'max_score': maxScore,
      'details': details,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// Copy with
  SectionResult copyWith({
    String? section,
    int? score,
    int? maxScore,
    Map<String, dynamic>? details,
    DateTime? completedAt,
  }) {
    return SectionResult(
      section: section ?? this.section,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      details: details ?? this.details,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
