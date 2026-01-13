import 'package:equatable/equatable.dart';

/// User model representing a staff member
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String workId;
  final String? username;
  final String role;
  final String? unit;
  final String? signatureUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Professional title (e.g., RSW, RPm, RN, MD)
  final String? title;

  /// Auto-generated employee ID (e.g., EMP-001)
  final String? employeeId;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.workId,
    this.username,
    required this.role,
    this.unit,
    this.signatureUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.title,
    this.employeeId,
  });

  /// Check if user is a super admin
  bool get isSuperAdmin => role == 'super_admin';

  /// Check if user is a center head
  bool get isCenterHead => role == 'center_head';

  /// Check if user is a unit head
  bool get isUnitHead =>
      role == 'head' || (role.endsWith('_head') && !isCenterHead);

  /// Check if user is staff
  bool get isStaff => role == 'staff' || role.endsWith('_staff');

  /// Check if user can add residents (Social Head only)
  bool get canAddResidents =>
      (role == 'head' && unit == 'social') || role == 'social_head';

  /// Check if user can administer MOCA-P (Psych Head only)
  bool get canAdministerMocaP =>
      (role == 'head' && unit == 'psych') || role == 'psych_head';

  /// Display name with title (e.g., "Juan Dela Cruz, RSW")
  String get displayNameWithTitle =>
      title != null ? '$fullName, $title' : fullName;

  /// Display employee ID with name (e.g., "EMP-001 - Juan Dela Cruz")
  String get displayWithEmployeeId =>
      employeeId != null ? '$employeeId - $fullName' : fullName;

  /// Check if user can provision users (Super Admin only)
  bool get canProvisionUsers => isSuperAdmin;

  /// Check if user can approve forms
  bool get canApprove => isUnitHead || isCenterHead || isSuperAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      workId: json['work_id'] as String? ?? '',
      username: json['username'] as String?,
      role: json['role'] as String? ?? 'staff',
      unit: json['unit'] as String?,
      signatureUrl: json['signature_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      title: json['title'] as String?,
      employeeId: json['employee_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'work_id': workId,
      'username': username,
      'role': role,
      'unit': unit,
      'signature_url': signatureUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'title': title,
      'employee_id': employeeId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? workId,
    String? username,
    String? role,
    String? unit,
    String? signatureUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? employeeId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      workId: workId ?? this.workId,
      username: username ?? this.username,
      role: role ?? this.role,
      unit: unit ?? this.unit,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        workId,
        username,
        role,
        unit,
        signatureUrl,
        isActive,
        createdAt,
        updatedAt,
        title,
        employeeId,
      ];
}
