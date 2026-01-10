/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'RCFMS';
  static const String appFullName = 'Resident Care & Facility Management System';

  /// Form status values
  static const String statusDraft = 'draft';
  static const String statusSubmitted = 'submitted';
  static const String statusPendingReview = 'pending_review';
  static const String statusApproved = 'approved';
  static const String statusReturned = 'returned';

  /// User roles (simplified per Blueprint)
  /// - Super Admin: System Owner & Security, Exclusive User Provisioning
  /// - Center Head: Operational Oversight, View Global Digital Timeline
  /// - Head: Service Unit Heads (Reviewers) - associated with a unit
  /// - Staff: Service Staff (Frontline) - associated with a unit
  static const String roleSuperAdmin = 'super_admin';
  static const String roleCenterHead = 'center_head';
  static const String roleHead = 'head';
  static const String roleStaff = 'staff';
  
  /// All available roles for user creation
  static const List<String> availableRoles = [
    roleStaff,
    roleHead,
    roleCenterHead,
    roleSuperAdmin,
  ];
  
  /// Roles that require a unit assignment
  static const List<String> rolesRequiringUnit = [
    roleStaff,
    roleHead,
  ];
  
  /// Admin roles (no unit required)
  static const List<String> adminRoles = [
    roleCenterHead,
    roleSuperAdmin,
  ];
  
  /// Check if role is admin level
  static bool isAdminRole(String role) => adminRoles.contains(role);
  
  /// Check if role requires unit assignment
  static bool requiresUnit(String role) => rolesRequiringUnit.contains(role);
  
  /// Check if user can manage residents (add/transfer)
  /// Per Blueprint: Social Head has "Gatekeeper" privileges
  static bool canManageResidents(String? role, String? unit) {
    // Super Admin and Center Head can always manage
    if (role == roleSuperAdmin || role == roleCenterHead) return true;
    // Social Head can manage residents
    if (role == roleHead && unit == unitSocial) return true;
    return false;
  }
  
  /// Check if user can approve/review forms
  static bool canApproveforms(String? role) {
    return role == roleSuperAdmin || 
           role == roleCenterHead || 
           role == roleHead;
  }

  /// Unit types
  static const String unitSocial = 'social';
  static const String unitMedical = 'medical';
  static const String unitPsych = 'psych';
  static const String unitRehab = 'rehab';
  static const String unitHomelife = 'homelife';

  /// Form template IDs by unit (matches FormTemplatesRegistry.templates)
  static const Map<String, List<String>> formTypesByUnit = {
    unitSocial: [
      'ss_pre_admission_checklist',
      'ss_requirements_checklist',
      'ss_general_intake',
      'ss_admission_conference',
      'ss_clients_contract',
      'ss_admission_slip',
      'ss_progress_notes',
      'ss_running_notes',
      'ss_intervention_plan',
      'ss_social_case_study',
      'ss_case_conference',
      'ss_termination_report',
      'ss_closing_summary',
      'ss_quarterly_narrative',
    ],
    unitMedical: [
      // Medical forms TBD
    ],
    unitPsych: [
      'ps_progress_notes',
      'ps_group_sessions',
      'ps_individual_sessions',
      'ps_inter_service_referral',
      'ps_initial_assessment',
      'ps_psychometrician_report',
    ],
    unitRehab: [
      // Rehab forms TBD
    ],
    unitHomelife: [
      'hl_inventory_admission',
      'hl_inventory_discharge',
      'hl_inventory_monthly',
      'hl_progress_notes',
      'hl_incident_report',
      'hl_out_on_pass',
    ],
  };

  /// Map service unit enum names to database unit values
  static String getUnitFromServiceUnit(String serviceUnitName) {
    switch (serviceUnitName) {
      case 'socialService':
        return unitSocial;
      case 'homeLifeService':
        return unitHomelife;
      case 'psychologicalService':
        return unitPsych;
      case 'medicalService':
        return unitMedical;
      default:
        return unitSocial;
    }
  }

  /// Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 500);

  /// Pagination
  static const int defaultPageSize = 20;

  /// Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
}
