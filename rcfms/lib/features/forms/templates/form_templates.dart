import 'package:flutter/material.dart';
import 'social_service_forms.dart';
import 'homelife_service_forms.dart';
import 'psychological_service_forms.dart';
import 'form_field_builders.dart';

export 'social_service_forms.dart';
export 'homelife_service_forms.dart';
export 'psychological_service_forms.dart';
export 'form_field_builders.dart';

/// Service unit types
enum ServiceUnit {
  socialService('Social Service'),
  homeLifeService('Home Life Service'),
  psychologicalService('Psychological Service'),
  medicalService('Medical Service');

  final String displayName;
  const ServiceUnit(this.displayName);
}

/// Form template definition
class FormTemplate {
  final String id;
  final String name;
  final String description;
  final ServiceUnit serviceUnit;
  final String templateType;
  final bool requiresSignature;
  final List<String> requiredSignatories;
  final IconData icon;

  const FormTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceUnit,
    required this.templateType,
    this.requiresSignature = true,
    this.requiredSignatories = const [],
    this.icon = Icons.description,
  });
}

/// Form Templates Registry
class FormTemplatesRegistry {
  FormTemplatesRegistry._();

  /// All available form templates
  static const List<FormTemplate> templates = [
    // ============ SOCIAL SERVICE ============
    FormTemplate(
      id: 'ss_pre_admission_checklist',
      name: 'Pre-Admission Checklist',
      description: 'Initial checklist for client pre-admission screening',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'pre_admission_checklist',
      icon: Icons.checklist,
    ),
    FormTemplate(
      id: 'ss_requirements_checklist',
      name: 'Requirements Checklist',
      description: 'Document requirements verification checklist',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'requirements_checklist',
      icon: Icons.fact_check,
    ),
    FormTemplate(
      id: 'ss_general_intake',
      name: 'General Intake Sheet',
      description: 'Initial client intake and assessment form',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'general_intake_sheet',
      requiredSignatories: ['Social Worker'],
      icon: Icons.person_add,
    ),
    FormTemplate(
      id: 'ss_admission_conference',
      name: 'Admission Case Conference',
      description: 'Case conference for client admission',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'admission_case_conference',
      requiredSignatories: ['Social Worker', 'Center Head'],
      icon: Icons.groups,
    ),
    FormTemplate(
      id: 'ss_clients_contract',
      name: 'Client\'s Contract',
      description: 'Agreement contract with client and custodian',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'clients_contract',
      requiredSignatories: ['Client/Relative', 'Witness', 'Center Head'],
      icon: Icons.handshake,
    ),
    FormTemplate(
      id: 'ss_admission_slip',
      name: 'Admission Slip',
      description: 'Official admission record slip',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'admission_slip',
      requiredSignatories: ['Medical Staff', 'Social Worker', 'Center Head'],
      icon: Icons.badge,
    ),
    FormTemplate(
      id: 'ss_progress_notes',
      name: 'Progress Notes',
      description: 'Regular client progress documentation',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'progress_notes',
      requiredSignatories: ['Social Worker'],
      icon: Icons.edit_note,
    ),
    FormTemplate(
      id: 'ss_running_notes',
      name: 'Running Notes',
      description: 'Continuous running notes for client',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'running_notes',
      requiredSignatories: ['Social Worker'],
      icon: Icons.notes,
    ),
    FormTemplate(
      id: 'ss_intervention_plan',
      name: 'Modified Intervention Plan',
      description: 'Client intervention plan with objectives and activities',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'intervention_plan',
      requiredSignatories: ['Client', 'Social Worker', 'Center Head'],
      icon: Icons.assignment,
    ),
    FormTemplate(
      id: 'ss_social_case_study',
      name: 'Updated Social Case Study Report',
      description: 'Comprehensive social case study report',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'social_case_study',
      requiredSignatories: ['Social Worker', 'Center Head'],
      icon: Icons.article,
    ),
    FormTemplate(
      id: 'ss_case_conference',
      name: 'Case Conference',
      description: 'Regular/Emergency/Pre-Discharge/Discharge case conference',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'case_conference',
      requiredSignatories: ['Social Worker', 'Center Head'],
      icon: Icons.meeting_room,
    ),
    FormTemplate(
      id: 'ss_termination_report',
      name: 'Termination Report',
      description: 'Case termination documentation',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'termination_report',
      requiredSignatories: ['Social Worker', 'Center Head', 'Division Chief', 'Regional Director'],
      icon: Icons.exit_to_app,
    ),
    FormTemplate(
      id: 'ss_closing_summary',
      name: 'Closing Summary',
      description: 'Case closing summary report',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'closing_summary',
      requiredSignatories: ['Social Worker', 'Center Head'],
      icon: Icons.summarize,
    ),
    FormTemplate(
      id: 'ss_quarterly_narrative',
      name: 'Quarterly Progress Narrative Report',
      description: 'Quarterly progress report covering all services',
      serviceUnit: ServiceUnit.socialService,
      templateType: 'quarterly_narrative',
      requiredSignatories: ['Social Worker', 'Center Head'],
      icon: Icons.calendar_month,
    ),

    // ============ HOME LIFE SERVICE ============
    FormTemplate(
      id: 'hl_inventory_admission',
      name: 'Inventory Upon Admission',
      description: 'Client belongings inventory at admission',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'inventory_admission',
      requiredSignatories: ['Referring Party', 'HP on Duty', 'Supervising HP', 'Center Head'],
      icon: Icons.inventory,
    ),
    FormTemplate(
      id: 'hl_inventory_discharge',
      name: 'Inventory Upon Discharge',
      description: 'Client belongings inventory at discharge',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'inventory_discharge',
      requiredSignatories: ['Receiving Party', 'HP on Duty', 'Supervising HP', 'Center Head'],
      icon: Icons.inventory_2,
    ),
    FormTemplate(
      id: 'hl_inventory_monthly',
      name: 'Monthly Inventory Report',
      description: 'Regular monthly inventory of client belongings',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'inventory_monthly',
      requiredSignatories: ['HP II', 'Supervising HP III', 'Center Head'],
      icon: Icons.inventory_2_outlined,
    ),
    FormTemplate(
      id: 'hl_progress_notes',
      name: 'Progress Notes',
      description: 'Home life service progress documentation',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'progress_notes',
      requiredSignatories: ['Houseparent I', 'Center Head'],
      icon: Icons.edit_note,
    ),
    FormTemplate(
      id: 'hl_incident_report',
      name: 'Incident Report',
      description: 'Documentation of incidents and actions taken',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'incident_report',
      requiredSignatories: ['HP on Duty', 'Supervising HP', 'Center Head'],
      icon: Icons.warning_amber,
    ),
    FormTemplate(
      id: 'hl_out_on_pass',
      name: 'Out on Pass',
      description: 'Client out-pass request and approval',
      serviceUnit: ServiceUnit.homeLifeService,
      templateType: 'out_on_pass',
      requiredSignatories: ['Supervising HP', 'Social Worker', 'Client', 'Center Head'],
      icon: Icons.door_front_door,
    ),

    // ============ PSYCHOLOGICAL SERVICE ============
    FormTemplate(
      id: 'ps_progress_notes',
      name: 'Progress Notes',
      description: 'Monthly psychological progress report',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'progress_notes',
      requiredSignatories: ['Psychometrician', 'Center Head'],
      icon: Icons.psychology,
    ),
    FormTemplate(
      id: 'ps_group_sessions',
      name: 'Group Sessions Report',
      description: 'Group therapy/activity session documentation',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'group_sessions',
      requiredSignatories: ['Psychometrician', 'Center Head'],
      icon: Icons.groups_2,
    ),
    FormTemplate(
      id: 'ps_individual_sessions',
      name: 'Individual Sessions Report',
      description: 'Individual therapy session documentation',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'individual_sessions',
      requiredSignatories: ['Psychometrician', 'Center Head'],
      icon: Icons.person,
    ),
    FormTemplate(
      id: 'ps_inter_service_referral',
      name: 'Inter-Service Referral',
      description: 'Referral form to psychological service',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'inter_service_referral',
      requiredSignatories: ['Referring Staff'],
      icon: Icons.send,
    ),
    FormTemplate(
      id: 'ps_initial_assessment',
      name: 'Initial Psychological Assessment',
      description: 'Initial psychological assessment for new clients',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'initial_assessment',
      requiredSignatories: ['Psychometrician', 'Center Head'],
      icon: Icons.assessment,
    ),
    FormTemplate(
      id: 'ps_psychometrician_report',
      name: 'Psychometrician\'s Report',
      description: 'Comprehensive psychometrician evaluation report',
      serviceUnit: ServiceUnit.psychologicalService,
      templateType: 'psychometrician_report',
      requiredSignatories: ['Psychometrician', 'Center Head'],
      icon: Icons.analytics,
    ),
  ];

  /// Get templates by service unit
  static List<FormTemplate> getByServiceUnit(ServiceUnit unit) {
    return templates.where((t) => t.serviceUnit == unit).toList();
  }

  /// Get template by ID
  static FormTemplate? getById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get template by templateType and unit
  static FormTemplate? getByTypeAndUnit(String templateType, String unit) {
    try {
      return templates.firstWhere((t) => 
        t.templateType == templateType && 
        _unitMatches(t.serviceUnit, unit)
      );
    } catch (e) {
      return null;
    }
  }

  /// Get template by templateType only (returns first match)
  static FormTemplate? getByType(String templateType) {
    try {
      return templates.firstWhere((t) => t.templateType == templateType);
    } catch (e) {
      return null;
    }
  }

  static bool _unitMatches(ServiceUnit serviceUnit, String unit) {
    switch (serviceUnit) {
      case ServiceUnit.socialService:
        return unit == 'social';
      case ServiceUnit.homeLifeService:
        return unit == 'homelife';
      case ServiceUnit.psychologicalService:
        return unit == 'psych';
      case ServiceUnit.medicalService:
        return unit == 'medical';
    }
  }

  /// Get form fields for a template
  static List<Widget> getFormFields(
    FormTemplate template,
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    switch (template.serviceUnit) {
      case ServiceUnit.socialService:
        return SocialServiceForms.getFormFields(
          template.templateType,
          data,
          onChanged,
        );
      case ServiceUnit.homeLifeService:
        return HomeLifeServiceForms.getFormFields(
          template.templateType,
          data,
          onChanged,
        );
      case ServiceUnit.psychologicalService:
        return PsychologicalServiceForms.getFormFields(
          template.templateType,
          data,
          onChanged,
        );
      case ServiceUnit.medicalService:
        // TODO: Add medical service forms
        return [const Text('Medical service forms coming soon')];
    }
  }

  /// Validate form data for a template
  static List<String> validateFormData(
    FormTemplate template,
    Map<String, dynamic> data,
  ) {
    final errors = <String>[];

    // Add template-specific validation here
    // This can be expanded based on required fields per template

    return errors;
  }

  /// Get initial/default data for a form
  static Map<String, dynamic> getDefaultData(FormTemplate template) {
    final now = DateTime.now();
    
    // Common default data
    final defaults = <String, dynamic>{
      'created_at': now.toIso8601String(),
      'template_id': template.id,
      'service_unit': template.serviceUnit.name,
    };

    // Template-specific defaults can be added here
    switch (template.templateType) {
      case 'inventory_admission':
      case 'inventory_discharge':
        defaults['admission_items'] = <Map<String, dynamic>>[];
        defaults['discharge_items'] = <Map<String, dynamic>>[];
        break;
      case 'inventory_monthly':
        defaults['clothing_items'] = <Map<String, dynamic>>[];
        defaults['toiletries_items'] = <Map<String, dynamic>>[];
        defaults['linen_items'] = <Map<String, dynamic>>[];
        defaults['others_items'] = <Map<String, dynamic>>[];
        defaults['month'] = _getMonthName(now.month);
        defaults['year'] = now.year.toString();
        break;
      case 'progress_notes':
        defaults['progress_entries'] = <Map<String, dynamic>>[];
        break;
      case 'incident_report':
        defaults['action_items'] = <Map<String, dynamic>>[];
        defaults['when_date'] = now.toIso8601String();
        break;
      case 'group_sessions':
        defaults['participant_details'] = <Map<String, dynamic>>[];
        defaults['session_date'] = now.toIso8601String();
        break;
      case 'initial_assessment':
      case 'psychometrician_report':
        defaults['intervention_items'] = <Map<String, dynamic>>[];
        defaults['date_of_assessment'] = now.toIso8601String();
        break;
      case 'quarterly_narrative':
        defaults['quarter'] = _getQuarter(now.month);
        break;
    }

    return defaults;
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  static String _getQuarter(int month) {
    if (month <= 3) return '1st';
    if (month <= 6) return '2nd';
    if (month <= 9) return '3rd';
    return '4th';
  }
}

/// Form status enum for the approval workflow
enum FormStatus {
  draft('Draft', 'Form is being filled out'),
  signedSubmitted('Signed & Submitted', 'Form has been signed and submitted'),
  pendingReview('Pending Review', 'Form is awaiting reviewer approval'),
  finalRecord('Final Record', 'Form has been approved and finalized'),
  returned('Returned', 'Form has been returned for corrections');

  final String label;
  final String description;
  const FormStatus(this.label, this.description);
}
