import 'package:equatable/equatable.dart';

/// Resident model representing an elderly resident
class ResidentModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String? photoUrl;
  final String wardId;
  final String? wardName;
  final String? roomNumber;
  final String? bedNumber;
  final DateTime admissionDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? medicalNotes;
  final String? allergies;
  final String? primaryDiagnosis;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const ResidentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    required this.wardId,
    this.wardName,
    this.roomNumber,
    this.bedNumber,
    required this.admissionDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.medicalNotes,
    this.allergies,
    this.primaryDiagnosis,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  /// Get full name
  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  /// Get age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Get display location
  String get displayLocation {
    final parts = <String>[];
    if (wardName != null) parts.add(wardName!);
    if (roomNumber != null) parts.add('Room $roomNumber');
    if (bedNumber != null) parts.add('Bed $bedNumber');
    return parts.join(' • ');
  }

  /// Alias for wardId (backward compatibility)
  String? get currentWardId => wardId;
  
  /// Generate resident code from ID
  String get residentCode => 'RES-${id.substring(0, 8).toUpperCase()}';
  
  /// Get status based on isActive
  String get status => isActive ? 'active' : 'discharged';

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String,
      photoUrl: json['photo_url'] as String?,
      wardId: json['ward_id'] as String,
      wardName: json['ward']?['name'] as String?,
      roomNumber: json['room_number'] as String?,
      bedNumber: json['bed_number'] as String?,
      admissionDate: DateTime.parse(json['admission_date'] as String),
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactRelation: json['emergency_contact_relation'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      allergies: json['allergies'] as String?,
      primaryDiagnosis: json['primary_diagnosis'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'gender': gender,
      'photo_url': photoUrl,
      'ward_id': wardId,
      'room_number': roomNumber,
      'bed_number': bedNumber,
      'admission_date': admissionDate.toIso8601String().split('T').first,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'medical_notes': medicalNotes,
      'allergies': allergies,
      'primary_diagnosis': primaryDiagnosis,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }

  ResidentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    String? wardId,
    String? wardName,
    String? roomNumber,
    String? bedNumber,
    DateTime? admissionDate,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? medicalNotes,
    String? allergies,
    String? primaryDiagnosis,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ResidentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      wardId: wardId ?? this.wardId,
      wardName: wardName ?? this.wardName,
      roomNumber: roomNumber ?? this.roomNumber,
      bedNumber: bedNumber ?? this.bedNumber,
      admissionDate: admissionDate ?? this.admissionDate,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      allergies: allergies ?? this.allergies,
      primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        middleName,
        dateOfBirth,
        gender,
        photoUrl,
        wardId,
        wardName,
        roomNumber,
        bedNumber,
        admissionDate,
        emergencyContactName,
        emergencyContactPhone,
        emergencyContactRelation,
        medicalNotes,
        allergies,
        primaryDiagnosis,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
