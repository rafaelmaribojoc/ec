import 'package:flutter/material.dart';
import 'form_field_builders.dart';

/// Social Service Form Templates
class SocialServiceForms {
  SocialServiceForms._();

  /// Get form fields for social service templates
  static List<Widget> getFormFields(
    String templateType,
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    switch (templateType) {
      case 'pre_admission_checklist':
        return _preAdmissionChecklist(data, onChanged);
      case 'requirements_checklist':
        return _requirementsChecklist(data, onChanged);
      case 'general_intake_sheet':
        return _generalIntakeSheet(data, onChanged);
      case 'admission_case_conference':
        return _admissionCaseConference(data, onChanged);
      case 'clients_contract':
        return _clientsContract(data, onChanged);
      case 'admission_slip':
        return _admissionSlip(data, onChanged);
      case 'progress_notes':
        return _progressNotes(data, onChanged);
      case 'running_notes':
        return _runningNotes(data, onChanged);
      case 'intervention_plan':
        return _interventionPlan(data, onChanged);
      case 'social_case_study':
        return _socialCaseStudy(data, onChanged);
      case 'case_conference':
        return _caseConference(data, onChanged);
      case 'termination_report':
        return _terminationReport(data, onChanged);
      case 'closing_summary':
        return _closingSummary(data, onChanged);
      case 'quarterly_narrative':
        return _quarterlyNarrative(data, onChanged);
      default:
        return [const Text('Unknown form type')];
    }
  }

  // PRE-ADMISSION CHECKLIST
  static List<Widget> _preAdmissionChecklist(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('PRE-ADMISSION CHECKLIST'),
      FormFieldBuilders.textField(
        label: 'Name',
        value: data['name'] ?? '',
        onChanged: (v) => onChanged('name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged('age', int.tryParse(v)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['date'],
              onChanged: (v) => onChanged('date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.dropdown(
        label: 'Category',
        value: data['category'] ?? 'abandoned',
        items: const ['Abandoned', 'Neglected', 'Unattached', 'Homeless'],
        onChanged: (v) => onChanged('category', v),
      ),
      FormFieldBuilders.textField(
        label: 'Place of Birth',
        value: data['place_of_birth'] ?? '',
        onChanged: (v) => onChanged('place_of_birth', v),
      ),
      FormFieldBuilders.textField(
        label: 'Referred by',
        value: data['referred_by'] ?? '',
        onChanged: (v) => onChanged('referred_by', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Remarks',
        value: data['remarks'] ?? '',
        onChanged: (v) => onChanged('remarks', v),
      ),
    ];
  }

  // REQUIREMENTS CHECKLIST
  static List<Widget> _requirementsChecklist(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final requirements = [
      'referral_letter',
      'social_case_study_report',
      'chest_xray',
      'medical_certificate',
      'laboratory_latest',
      'blood_chemistry',
      'urinalysis',
      'stool_exam',
      'ultrasound',
      'psychological_evaluation',
      'vaccination_card',
      'rt_pcr_antigen',
      'osca_id',
    ];

    final labels = {
      'referral_letter': 'Referral Letter',
      'social_case_study_report': 'Social Case Study Report',
      'chest_xray': 'Chest X-Ray',
      'medical_certificate': 'Medical Certificate',
      'laboratory_latest': 'Laboratory (Latest)',
      'blood_chemistry': 'Blood Chemistry (FBS, SGPT, SGOT, Uric, Creatinine, Cholesterol, BUN, Electrolytes)',
      'urinalysis': 'Urinalysis',
      'stool_exam': 'Stool Exam',
      'ultrasound': 'Ultrasound (if needed)',
      'psychological_evaluation': 'Psychological Evaluation',
      'vaccination_card': 'Vaccination Card',
      'rt_pcr_antigen': 'RT-PCR / Antigen Result',
      'osca_id': 'OSCA ID',
    };

    return [
      FormFieldBuilders.sectionHeader('REQUIREMENTS CHECKLIST'),
      FormFieldBuilders.textField(
        label: 'Name',
        value: data['name'] ?? '',
        onChanged: (v) => onChanged('name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              onChanged: (v) => onChanged('age', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['checklist_date'],
              onChanged: (v) => onChanged('checklist_date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.dropdown(
        label: 'Category',
        value: data['category'] ?? 'abandoned',
        items: const ['Abandoned', 'Neglected', 'Unattached', 'Homeless'],
        onChanged: (v) => onChanged('category', v),
      ),
      FormFieldBuilders.textField(
        label: 'Place of Birth',
        value: data['place_of_birth'] ?? '',
        onChanged: (v) => onChanged('place_of_birth', v),
      ),
      FormFieldBuilders.textField(
        label: 'Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      FormFieldBuilders.textField(
        label: 'Referred by',
        value: data['referred_by'] ?? '',
        onChanged: (v) => onChanged('referred_by', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Requirements Status'),
      ...requirements.map((req) => FormFieldBuilders.checkboxWithRemarks(
        label: labels[req]!,
        checked: data['req_${req}_yes'] ?? false,
        remarks: data['req_${req}_remarks'] ?? '',
        onCheckedChanged: (v) => onChanged('req_${req}_yes', v),
        onRemarksChanged: (v) => onChanged('req_${req}_remarks', v),
      )),
      const SizedBox(height: 16),
      FormFieldBuilders.textField(
        label: 'Endorsed by',
        value: data['endorsed_by'] ?? '',
        onChanged: (v) => onChanged('endorsed_by', v),
      ),
      FormFieldBuilders.textField(
        label: 'Received by',
        value: data['received_by'] ?? '',
        onChanged: (v) => onChanged('received_by', v),
      ),
    ];
  }

  // GENERAL INTAKE SHEET
  static List<Widget> _generalIntakeSheet(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('GENERAL INTAKE SHEET'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Case No.',
              value: data['case_no'] ?? '',
              onChanged: (v) => onChanged('case_no', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['intake_date'],
              onChanged: (v) => onChanged('intake_date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.dropdown(
        label: 'Case Type',
        value: data['case_type'] ?? 'new',
        items: const ['New', 'Re-opened'],
        onChanged: (v) => onChanged('case_type', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Identifying Information'),
      FormFieldBuilders.textField(
        label: 'Name of Applicant',
        value: data['applicant_name'] ?? '',
        onChanged: (v) => onChanged('applicant_name', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Address',
        value: data['applicant_address'] ?? '',
        onChanged: (v) => onChanged('applicant_address', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Birthplace',
              value: data['birthplace'] ?? '',
              onChanged: (v) => onChanged('birthplace', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Birthday',
              value: data['birthday'],
              onChanged: (v) => onChanged('birthday', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Name of Nearest Relative',
        value: data['nearest_relative_name'] ?? '',
        onChanged: (v) => onChanged('nearest_relative_name', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Address of Nearest Relative',
        value: data['nearest_relative_address'] ?? '',
        onChanged: (v) => onChanged('nearest_relative_address', v),
      ),
      FormFieldBuilders.textArea(
        label: 'If applicant is disabled, indicate nature of disability',
        value: data['disability_nature'] ?? '',
        onChanged: (v) => onChanged('disability_nature', v),
      ),
      FormFieldBuilders.textField(
        label: 'Source of Referral',
        value: data['referral_source'] ?? '',
        onChanged: (v) => onChanged('referral_source', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Assessment'),
      FormFieldBuilders.textArea(
        label: 'Problem Presented',
        value: data['problem_presented'] ?? '',
        onChanged: (v) => onChanged('problem_presented', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Initial Assessment (Worker\'s impression about the problem and its causes)',
        value: data['initial_assessment'] ?? '',
        onChanged: (v) => onChanged('initial_assessment', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Action Taken',
        value: data['action_taken'] ?? '',
        onChanged: (v) => onChanged('action_taken', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Assessment and Recommendation',
        value: data['assessment_recommendation'] ?? '',
        onChanged: (v) => onChanged('assessment_recommendation', v),
      ),
    ];
  }

  // ADMISSION CASE CONFERENCE
  static List<Widget> _admissionCaseConference(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return _caseConferenceBase('ADMISSION CASE CONFERENCE', data, onChanged);
  }

  // Case Conference Base (shared layout)
  static List<Widget> _caseConferenceBase(
    String title,
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader(title),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.textField(
        label: 'Age',
        value: data['client_age']?.toString() ?? '',
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged('client_age', v),
      ),
      FormFieldBuilders.datePicker(
        label: 'Date Admitted',
        value: data['date_admitted'],
        onChanged: (v) => onChanged('date_admitted', v?.toIso8601String()),
      ),
      FormFieldBuilders.dropdown(
        label: 'Case Category',
        value: data['case_category'] ?? 'abandoned',
        items: const ['Abandoned', 'Neglected', 'Unattached', 'Homeless'],
        onChanged: (v) => onChanged('case_category', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Condition',
        value: data['condition'] ?? '',
        onChanged: (v) => onChanged('condition', v),
      ),
      FormFieldBuilders.textField(
        label: 'Venue',
        value: data['venue'] ?? '',
        onChanged: (v) => onChanged('venue', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Conference',
              value: data['conference_date'],
              onChanged: (v) => onChanged('conference_date', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Time Allotted',
              value: data['time_allotted'] ?? '',
              onChanged: (v) => onChanged('time_allotted', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textArea(
        label: 'Present (Attendees)',
        value: data['attendees'] ?? '',
        onChanged: (v) => onChanged('attendees', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Objective',
        value: data['objective'] ?? '',
        onChanged: (v) => onChanged('objective', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Discussions'),
      FormFieldBuilders.textArea(
        label: 'Discussion Points',
        value: data['discussions'] ?? '',
        onChanged: (v) => onChanged('discussions', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Agreement Reached / Recommendations',
        value: data['agreement_recommendations'] ?? '',
        onChanged: (v) => onChanged('agreement_recommendations', v),
      ),
    ];
  }

  // CLIENT'S CONTRACT
  static List<Widget> _clientsContract(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('CLIENT\'S CONTRACT'),
      FormFieldBuilders.textField(
        label: 'Client Name',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.textField(
        label: 'Status',
        value: data['status'] ?? '',
        onChanged: (v) => onChanged('status', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      FormFieldBuilders.textField(
        label: 'Custodian Name',
        value: data['custodian_name'] ?? '',
        onChanged: (v) => onChanged('custodian_name', v),
      ),
      FormFieldBuilders.datePicker(
        label: 'Date Admitted',
        value: data['date_admitted'],
        onChanged: (v) => onChanged('date_admitted', v?.toIso8601String()),
      ),
      FormFieldBuilders.textField(
        label: 'Referred By',
        value: data['referred_by'] ?? '',
        onChanged: (v) => onChanged('referred_by', v),
      ),
      FormFieldBuilders.datePicker(
        label: 'Contract Date',
        value: data['contract_date'],
        onChanged: (v) => onChanged('contract_date', v?.toIso8601String()),
      ),
      FormFieldBuilders.textField(
        label: 'Witness 1',
        value: data['witness_1'] ?? '',
        onChanged: (v) => onChanged('witness_1', v),
      ),
      FormFieldBuilders.textField(
        label: 'Witness 2 (C/MSWDO)',
        value: data['witness_2'] ?? '',
        onChanged: (v) => onChanged('witness_2', v),
      ),
    ];
  }

  // ADMISSION SLIP
  static List<Widget> _admissionSlip(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('ADMISSION SLIP'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['admission_date'],
              onChanged: (v) => onChanged('admission_date', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.timePicker(
              label: 'Time',
              value: data['admission_time'],
              onChanged: (v) => onChanged('admission_time', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Case Control No.',
        value: data['case_control_no'] ?? '',
        onChanged: (v) => onChanged('case_control_no', v),
      ),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.textField(
        label: 'Age',
        value: data['client_age']?.toString() ?? '',
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged('client_age', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Complete Address',
        value: data['complete_address'] ?? '',
        onChanged: (v) => onChanged('complete_address', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Civil Status',
              value: data['civil_status'] ?? 'single',
              items: const ['Single', 'Married', 'Widowed', 'Separated'],
              onChanged: (v) => onChanged('civil_status', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Religion',
              value: data['religion'] ?? '',
              onChanged: (v) => onChanged('religion', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Educational Attainment',
        value: data['educational_attainment'] ?? '',
        onChanged: (v) => onChanged('educational_attainment', v),
      ),
      FormFieldBuilders.textField(
        label: 'Referred by',
        value: data['referred_by'] ?? '',
        onChanged: (v) => onChanged('referred_by', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Complete Address of Referring Party',
        value: data['referring_party_address'] ?? '',
        onChanged: (v) => onChanged('referring_party_address', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Name and Address of Nearest Relative',
        value: data['nearest_relative'] ?? '',
        onChanged: (v) => onChanged('nearest_relative', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Medical Findings / Clearance',
        value: data['medical_findings'] ?? '',
        onChanged: (v) => onChanged('medical_findings', v),
      ),
      FormFieldBuilders.textField(
        label: 'Assigned to Room',
        value: data['assigned_room'] ?? '',
        onChanged: (v) => onChanged('assigned_room', v),
      ),
    ];
  }

  // PROGRESS NOTES
  static List<Widget> _progressNotes(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('PROGRESS NOTES'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['progress_date'],
        onChanged: (v) => onChanged('progress_date', v?.toIso8601String()),
      ),
      FormFieldBuilders.textArea(
        label: 'Observations',
        value: data['observations'] ?? '',
        onChanged: (v) => onChanged('observations', v),
        required: true,
        maxLines: 8,
      ),
      FormFieldBuilders.textArea(
        label: 'Supervisory Remarks',
        value: data['supervisory_remarks'] ?? '',
        onChanged: (v) => onChanged('supervisory_remarks', v),
      ),
    ];
  }

  // RUNNING NOTES
  static List<Widget> _runningNotes(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('RUNNING NOTES'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['running_date'],
        onChanged: (v) => onChanged('running_date', v?.toIso8601String()),
      ),
      FormFieldBuilders.textArea(
        label: 'Notes / Observations',
        value: data['notes'] ?? '',
        onChanged: (v) => onChanged('notes', v),
        required: true,
        maxLines: 10,
      ),
      FormFieldBuilders.textArea(
        label: 'Supervisory Remarks',
        value: data['supervisory_remarks'] ?? '',
        onChanged: (v) => onChanged('supervisory_remarks', v),
      ),
    ];
  }

  // INTERVENTION PLAN
  static List<Widget> _interventionPlan(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('MODIFIED INTERVENTION PLAN'),
      FormFieldBuilders.datePicker(
        label: 'Date Prepared',
        value: data['date_prepared'],
        onChanged: (v) => onChanged('date_prepared', v?.toIso8601String()),
      ),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.textField(
        label: 'Case Control No.',
        value: data['case_control_no'] ?? '',
        onChanged: (v) => onChanged('case_control_no', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Goal (In 3 months time, client\'s social functioning will be...)',
        value: data['goal'] ?? '',
        onChanged: (v) => onChanged('goal', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Intervention Details'),
      FormFieldBuilders.textArea(
        label: 'Objectives',
        value: data['objectives'] ?? '',
        onChanged: (v) => onChanged('objectives', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Activities',
        value: data['activities'] ?? '',
        onChanged: (v) => onChanged('activities', v),
      ),
      FormFieldBuilders.textField(
        label: 'Time Frame',
        value: data['time_frame'] ?? '',
        onChanged: (v) => onChanged('time_frame', v),
      ),
      FormFieldBuilders.textField(
        label: 'Responsible Unit/Person',
        value: data['responsible_person'] ?? '',
        onChanged: (v) => onChanged('responsible_person', v),
      ),
    ];
  }

  // SOCIAL CASE STUDY REPORT
  static List<Widget> _socialCaseStudy(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('UPDATED SOCIAL CASE STUDY REPORT'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['report_date'],
              onChanged: (v) => onChanged('report_date', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Year Admitted',
              value: data['year_admitted'] ?? '',
              onChanged: (v) => onChanged('year_admitted', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Case No.',
              value: data['case_no'] ?? '',
              onChanged: (v) => onChanged('case_no', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Length of Stay',
              value: data['length_of_stay'] ?? '',
              onChanged: (v) => onChanged('length_of_stay', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.dropdown(
        label: 'Older Person Category',
        value: data['category'] ?? 'abandoned',
        items: const ['Abandoned', 'Neglected', 'Unattached', 'Homeless'],
        onChanged: (v) => onChanged('category', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Identifying Data'),
      FormFieldBuilders.textField(
        label: 'Name',
        value: data['name'] ?? '',
        onChanged: (v) => onChanged('name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              onChanged: (v) => onChanged('age', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Sex',
              value: data['sex'] ?? 'male',
              items: const ['Male', 'Female'],
              onChanged: (v) => onChanged('sex', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Civil Status',
              value: data['civil_status'] ?? 'single',
              items: const ['Single', 'Married', 'Widowed', 'Separated'],
              onChanged: (v) => onChanged('civil_status', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Birth Date',
              value: data['birth_date'],
              onChanged: (v) => onChanged('birth_date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Birth Place',
        value: data['birth_place'] ?? '',
        onChanged: (v) => onChanged('birth_place', v),
      ),
      FormFieldBuilders.textField(
        label: 'Educational Attainment',
        value: data['educational_attainment'] ?? '',
        onChanged: (v) => onChanged('educational_attainment', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Provincial/City Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      FormFieldBuilders.textField(
        label: 'Source of Referral',
        value: data['referral_source'] ?? '',
        onChanged: (v) => onChanged('referral_source', v),
      ),
      FormFieldBuilders.textField(
        label: 'Name of Referring Party',
        value: data['referring_party'] ?? '',
        onChanged: (v) => onChanged('referring_party', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Case Details'),
      FormFieldBuilders.textArea(
        label: 'Family Composition',
        value: data['family_composition'] ?? '',
        onChanged: (v) => onChanged('family_composition', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Problem Presented',
        value: data['problem_presented'] ?? '',
        onChanged: (v) => onChanged('problem_presented', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Findings',
        value: data['findings'] ?? '',
        onChanged: (v) => onChanged('findings', v),
      ),
      FormFieldBuilders.textArea(
        label: 'History',
        value: data['history'] ?? '',
        onChanged: (v) => onChanged('history', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Medical and Nutritional Needs',
        value: data['medical_nutritional_needs'] ?? '',
        onChanged: (v) => onChanged('medical_nutritional_needs', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Present Status',
        value: data['present_status'] ?? '',
        onChanged: (v) => onChanged('present_status', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Action Taken / Service Provided',
        value: data['action_taken'] ?? '',
        onChanged: (v) => onChanged('action_taken', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Assessment and Recommendation',
        value: data['assessment_recommendation'] ?? '',
        onChanged: (v) => onChanged('assessment_recommendation', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Intervention Plan',
        value: data['intervention_plan'] ?? '',
        onChanged: (v) => onChanged('intervention_plan', v),
      ),
    ];
  }

  // CASE CONFERENCE (Regular/Emergency/Discharge)
  static List<Widget> _caseConference(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.dropdown(
        label: 'Conference Type',
        value: data['conference_type'] ?? 'regular',
        items: const ['Regular', 'Emergency', 'Pre-Discharge', 'Discharge'],
        onChanged: (v) => onChanged('conference_type', v),
      ),
      ..._caseConferenceBase('CASE CONFERENCE', data, onChanged),
    ];
  }

  // TERMINATION REPORT
  static List<Widget> _terminationReport(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('TERMINATION REPORT'),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['termination_date'],
        onChanged: (v) => onChanged('termination_date', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Identifying Information'),
      FormFieldBuilders.textField(
        label: 'Client Name',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Reason for Client\'s Admission at the Home for the Aged',
        value: data['admission_reason'] ?? '',
        onChanged: (v) => onChanged('admission_reason', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Intervention Provided by the HA',
        value: data['intervention_provided'] ?? '',
        onChanged: (v) => onChanged('intervention_provided', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Social Functioning of the Resident Upon Discharge',
        value: data['social_functioning'] ?? '',
        onChanged: (v) => onChanged('social_functioning', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Why the Case is Being Closed',
        value: data['closing_reason'] ?? '',
        onChanged: (v) => onChanged('closing_reason', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Recommendations',
        value: data['recommendations'] ?? '',
        onChanged: (v) => onChanged('recommendations', v),
      ),
    ];
  }

  // CLOSING SUMMARY
  static List<Widget> _closingSummary(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('CLOSING SUMMARY'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date',
              value: data['closing_date'],
              onChanged: (v) => onChanged('closing_date', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Case No.',
              value: data['case_no'] ?? '',
              onChanged: (v) => onChanged('case_no', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Name',
        value: data['name'] ?? '',
        onChanged: (v) => onChanged('name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              onChanged: (v) => onChanged('age', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Gender',
              value: data['gender'] ?? 'male',
              items: const ['Male', 'Female'],
              onChanged: (v) => onChanged('gender', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textArea(
        label: 'Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      FormFieldBuilders.textField(
        label: 'Source of Referral',
        value: data['referral_source'] ?? '',
        onChanged: (v) => onChanged('referral_source', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Address of Referring Party',
        value: data['referring_party_address'] ?? '',
        onChanged: (v) => onChanged('referring_party_address', v),
      ),
      FormFieldBuilders.datePicker(
        label: 'Date Admitted',
        value: data['date_admitted'],
        onChanged: (v) => onChanged('date_admitted', v?.toIso8601String()),
      ),
      FormFieldBuilders.datePicker(
        label: 'Date of Discharge',
        value: data['date_discharged'],
        onChanged: (v) => onChanged('date_discharged', v?.toIso8601String()),
      ),
      FormFieldBuilders.textArea(
        label: 'Summary of Case',
        value: data['case_summary'] ?? '',
        onChanged: (v) => onChanged('case_summary', v),
        required: true,
        maxLines: 8,
      ),
    ];
  }

  // QUARTERLY PROGRESS NARRATIVE REPORT
  static List<Widget> _quarterlyNarrative(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('QUARTERLY PROGRESS NARRATIVE REPORT'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['report_date'],
        onChanged: (v) => onChanged('report_date', v?.toIso8601String()),
      ),
      FormFieldBuilders.dropdown(
        label: 'Quarter',
        value: data['quarter'] ?? '1st',
        items: const ['1st', '2nd', '3rd', '4th'],
        onChanged: (v) => onChanged('quarter', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Service Reports'),
      FormFieldBuilders.textArea(
        label: 'Social Service',
        value: data['social_service'] ?? '',
        onChanged: (v) => onChanged('social_service', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Medical Service',
        value: data['medical_service'] ?? '',
        onChanged: (v) => onChanged('medical_service', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Psych Service',
        value: data['psych_service'] ?? '',
        onChanged: (v) => onChanged('psych_service', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Homelife Service',
        value: data['homelife_service'] ?? '',
        onChanged: (v) => onChanged('homelife_service', v),
      ),
      FormFieldBuilders.textArea(
        label: 'PSD Service',
        value: data['psd_service'] ?? '',
        onChanged: (v) => onChanged('psd_service', v),
      ),
    ];
  }
}
