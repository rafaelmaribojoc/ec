import 'package:flutter/material.dart';
import 'form_field_builders.dart';

/// Psychological Service Form Templates
class PsychologicalServiceForms {
  PsychologicalServiceForms._();

  /// Get form fields for psychological service templates
  /// [readOnly] - If true, all fields will be disabled (for approval view)
  /// Note: The readOnly parameter is handled by the caller (FormContentWidget)
  /// using IgnorePointer wrapper, so we don't need to pass it to each method
  static List<Widget> getFormFields(
    String templateType,
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged, {
    bool readOnly = false,
  }) {
    switch (templateType) {
      case 'progress_notes':
        return _progressNotes(data, onChanged);
      case 'group_sessions':
        return _groupSessionsReport(data, onChanged);
      case 'individual_sessions':
        return _individualSessionsReport(data, onChanged);
      case 'inter_service_referral':
        return _interServiceReferral(data, onChanged);
      case 'initial_assessment':
        return _initialPsychologicalAssessment(data, onChanged);
      case 'psychometrician_report':
        return _psychometricianReport(data, onChanged);
      default:
        return [const Text('Unknown form type')];
    }
  }

  // PROGRESS NOTES
  static List<Widget> _progressNotes(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('PROGRESS NOTES'),
      FormFieldBuilders.infoText(
          'Monthly progress report for psychological services'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Coverage Month',
              value: data['coverage_month'] ?? 'January',
              items: const [
                'January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December'
              ],
              onChanged: (v) => onChanged('coverage_month', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Year',
              value: data['coverage_year']?.toString() ??
                  DateTime.now().year.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged('coverage_year', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.datePicker(
        label: 'Date Submitted',
        value: data['date_submitted'],
        onChanged: (v) => onChanged('date_submitted', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Observations / Findings'),
      FormFieldBuilders.textArea(
        label: 'Mental Health Status',
        value: data['mental_health_status'] ?? '',
        onChanged: (v) => onChanged('mental_health_status', v),
        required: true,
        maxLines: 4,
      ),
      FormFieldBuilders.textArea(
        label: 'Activities of Daily Living (ADL)',
        value: data['adl_status'] ?? '',
        onChanged: (v) => onChanged('adl_status', v),
        maxLines: 4,
      ),
      FormFieldBuilders.textArea(
        label: 'Socio-Emotional (Demonstrates)',
        value: data['socio_emotional'] ?? '',
        onChanged: (v) => onChanged('socio_emotional', v),
        maxLines: 4,
      ),
      FormFieldBuilders.textArea(
        label: 'Supervisory Remarks',
        value: data['supervisory_remarks'] ?? '',
        onChanged: (v) => onChanged('supervisory_remarks', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Ways Forward'),
      FormFieldBuilders.textArea(
        label: 'Recommendations / Next Steps',
        value: data['ways_forward'] ?? '',
        onChanged: (v) => onChanged('ways_forward', v),
        required: true,
        maxLines: 4,
      ),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldBuilders.textField(
                  label: 'Prepared By',
                  value: data['prepared_by'] ?? '',
                  onChanged: (v) => onChanged('prepared_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['prepared_by_position'] ?? 'Psychometrician',
                  onChanged: (v) => onChanged('prepared_by_position', v),
                ),
                FormFieldBuilders.textField(
                  label: 'License No.',
                  value: data['license_no'] ?? '',
                  onChanged: (v) => onChanged('license_no', v),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldBuilders.textField(
                  label: 'Noted By',
                  value: data['noted_by'] ?? '',
                  onChanged: (v) => onChanged('noted_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['noted_by_position'] ?? 'Center Head',
                  onChanged: (v) => onChanged('noted_by_position', v),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // GROUP SESSIONS REPORT
  static List<Widget> _groupSessionsReport(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final participants = (data['participant_details'] as List<dynamic>?) ?? [];

    return [
      FormFieldBuilders.sectionHeader('GROUP SESSIONS REPORT'),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Strictly Confidential / Not for Legal Use',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Session Type'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'By Referral',
              value: data['type_referral'] ?? false,
              onChanged: (v) => onChanged('type_referral', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'Walk-in',
              value: data['type_walkin'] ?? false,
              onChanged: (v) => onChanged('type_walkin', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'As Need Arises',
              value: data['type_as_needed'] ?? false,
              onChanged: (v) => onChanged('type_as_needed', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Session',
              value: data['session_date'],
              onChanged: (v) => onChanged('session_date', v?.toIso8601String()),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Report',
              value: data['report_date'],
              onChanged: (v) => onChanged('report_date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Session Details'),
      FormFieldBuilders.textArea(
        label: 'Reason for Session',
        value: data['reason_for_session'] ?? '',
        onChanged: (v) => onChanged('reason_for_session', v),
        required: true,
        hint: 'Insert brief and specific reason',
      ),
      FormFieldBuilders.textArea(
        label: 'Participants',
        value: data['participants'] ?? '',
        onChanged: (v) => onChanged('participants', v),
        required: true,
        hint: 'Insert names / names per batch (if done in batches)',
      ),
      FormFieldBuilders.textArea(
        label: 'Objectives of the Session',
        value: data['objectives'] ?? '',
        onChanged: (v) => onChanged('objectives', v),
        hint: 'Enumerate using SMART technique',
      ),
      FormFieldBuilders.textArea(
        label: 'Session Narrative',
        value: data['session_narrative'] ?? '',
        onChanged: (v) => onChanged('session_narrative', v),
        required: true,
        maxLines: 6,
        hint:
            'Describe how the session happened, behavioral observations (FIDS format if possible)',
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader(
          'Participant-Specific Agreements (Optional)'),
      FormFieldBuilders.infoText(
        'Use this table if participants have unique needs requiring individual agreements or lessons.',
      ),
      FormFieldBuilders.tableHeader(
        ['Participant', 'Challenges', 'Agreements/Lessons Imparted'],
        flexValues: [2, 3, 3],
      ),
      ...participants.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        return FormFieldBuilders.tableRow(
          cells: [
            TextFormField(
              initialValue: item['name'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Name...',
              ),
              onChanged: (v) {
                final newParticipants =
                    List<Map<String, dynamic>>.from(participants);
                newParticipants[index]['name'] = v;
                onChanged('participant_details', newParticipants);
              },
            ),
            TextFormField(
              initialValue: item['challenges'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Challenges...',
              ),
              maxLines: 2,
              onChanged: (v) {
                final newParticipants =
                    List<Map<String, dynamic>>.from(participants);
                newParticipants[index]['challenges'] = v;
                onChanged('participant_details', newParticipants);
              },
            ),
            TextFormField(
              initialValue: item['agreements'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Agreements...',
              ),
              maxLines: 2,
              onChanged: (v) {
                final newParticipants =
                    List<Map<String, dynamic>>.from(participants);
                newParticipants[index]['agreements'] = v;
                onChanged('participant_details', newParticipants);
              },
            ),
          ],
          flexValues: [2, 3, 3],
          onDelete: () {
            final newParticipants =
                List<Map<String, dynamic>>.from(participants);
            newParticipants.removeAt(index);
            onChanged('participant_details', newParticipants);
          },
        );
      }),
      FormFieldBuilders.addRowButton(() {
        final newParticipants = List<Map<String, dynamic>>.from(participants);
        newParticipants.add({
          'name': '',
          'challenges': '',
          'agreements': '',
        });
        onChanged('participant_details', newParticipants);
      }),
      FormFieldBuilders.textArea(
        label: 'General Agreements/Lessons Imparted',
        value: data['general_agreements'] ?? '',
        onChanged: (v) => onChanged('general_agreements', v),
        hint:
            'Common agreements/lessons for all. Provide concluding statement(s).',
      ),
      FormFieldBuilders.textArea(
        label: 'Recommendations',
        value: data['recommendations'] ?? '',
        onChanged: (v) => onChanged('recommendations', v),
        required: true,
        hint: 'SMART recommendations in line with the reason for session',
      ),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Prepared By',
                  value: data['prepared_by'] ?? '',
                  onChanged: (v) => onChanged('prepared_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['prepared_by_position'] ?? 'Psychometrician',
                  onChanged: (v) => onChanged('prepared_by_position', v),
                ),
                FormFieldBuilders.textField(
                  label: 'License No.',
                  value: data['license_no'] ?? '',
                  onChanged: (v) => onChanged('license_no', v),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Noted By',
                  value: data['noted_by'] ?? '',
                  onChanged: (v) => onChanged('noted_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['noted_by_position'] ?? 'Center Head',
                  onChanged: (v) => onChanged('noted_by_position', v),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // INDIVIDUAL SESSIONS REPORT
  static List<Widget> _individualSessionsReport(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('INDIVIDUAL SESSIONS REPORT'),
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Department of Social Welfare and Development XI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Home for the Aged'),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Strictly Confidential / Not for Legal Use',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Session Type'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'By Referral',
              value: data['type_referral'] ?? false,
              onChanged: (v) => onChanged('type_referral', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'Walk-in',
              value: data['type_walkin'] ?? false,
              onChanged: (v) => onChanged('type_walkin', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'As Need Arises',
              value: data['type_as_needed'] ?? false,
              onChanged: (v) => onChanged('type_as_needed', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Client Name',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Session',
              value: data['session_date'],
              onChanged: (v) => onChanged('session_date', v?.toIso8601String()),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Report',
              value: data['report_date'],
              onChanged: (v) => onChanged('report_date', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Session Details'),
      FormFieldBuilders.textArea(
        label: 'Reason for Session',
        value: data['reason_for_session'] ?? '',
        onChanged: (v) => onChanged('reason_for_session', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'Objectives of the Session',
        value: data['objectives'] ?? '',
        onChanged: (v) => onChanged('objectives', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Session Narrative',
        value: data['session_narrative'] ?? '',
        onChanged: (v) => onChanged('session_narrative', v),
        required: true,
        maxLines: 8,
      ),
      FormFieldBuilders.textArea(
        label: 'Agreements/Lessons Imparted',
        value: data['agreements'] ?? '',
        onChanged: (v) => onChanged('agreements', v),
      ),
      FormFieldBuilders.textArea(
        label: 'Recommendations',
        value: data['recommendations'] ?? '',
        onChanged: (v) => onChanged('recommendations', v),
        required: true,
      ),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Prepared By',
                  value: data['prepared_by'] ?? '',
                  onChanged: (v) => onChanged('prepared_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['prepared_by_position'] ?? 'Psychometrician',
                  onChanged: (v) => onChanged('prepared_by_position', v),
                ),
                FormFieldBuilders.textField(
                  label: 'License No.',
                  value: data['license_no'] ?? '',
                  onChanged: (v) => onChanged('license_no', v),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Noted By',
                  value: data['noted_by'] ?? '',
                  onChanged: (v) => onChanged('noted_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['noted_by_position'] ?? 'Center Head',
                  onChanged: (v) => onChanged('noted_by_position', v),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // INTER-SERVICE REFERRAL
  static List<Widget> _interServiceReferral(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('INTER-SERVICE REFERRAL FORM'),
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Department of Social Welfare and Development – XI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Home for the Aged'),
            Text('Visayan Village, Tagum City, Davao del Norte'),
            SizedBox(height: 8),
            Text(
              'Psychological Service',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      FormFieldBuilders.datePicker(
        label: 'Date of Referral',
        value: data['referral_date'],
        onChanged: (v) => onChanged('referral_date', v?.toIso8601String()),
        required: true,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Client Information'),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: FormFieldBuilders.textField(
              label: 'Name',
              value: data['client_name'] ?? '',
              onChanged: (v) => onChanged('client_name', v),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Nickname',
              value: data['nickname'] ?? '',
              onChanged: (v) => onChanged('nickname', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Birth',
              value: data['date_of_birth'],
              onChanged: (v) =>
                  onChanged('date_of_birth', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged('age', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Ward/Room',
        value: data['ward_room'] ?? '',
        onChanged: (v) => onChanged('ward_room', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Referral Details'),
      FormFieldBuilders.textArea(
        label: 'Reason for Referral',
        value: data['reason_for_referral'] ?? '',
        onChanged: (v) => onChanged('reason_for_referral', v),
        required: true,
        maxLines: 4,
      ),
      FormFieldBuilders.textArea(
        label: 'Challenges Presented',
        value: data['challenges_presented'] ?? '',
        onChanged: (v) => onChanged('challenges_presented', v),
        required: true,
        maxLines: 6,
      ),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Referring Party'),
      FormFieldBuilders.textField(
        label: 'Name',
        value: data['referring_person'] ?? '',
        onChanged: (v) => onChanged('referring_person', v),
      ),
      FormFieldBuilders.textField(
        label: 'Position',
        value: data['referring_position'] ?? '',
        onChanged: (v) => onChanged('referring_position', v),
      ),
      FormFieldBuilders.textField(
        label: 'Unit / Service',
        value: data['referring_unit'] ?? '',
        onChanged: (v) => onChanged('referring_unit', v),
      ),
    ];
  }

  // INITIAL PSYCHOLOGICAL ASSESSMENT
  static List<Widget> _initialPsychologicalAssessment(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final interventions = (data['intervention_items'] as List<dynamic>?) ?? [];

    return [
      FormFieldBuilders.sectionHeader('INITIAL PSYCHOLOGICAL ASSESSMENT'),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Strictly Confidential / Not for Legal Use',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('I. Identifying Data'),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: FormFieldBuilders.textField(
              label: 'Name',
              value: data['name'] ?? '',
              onChanged: (v) => onChanged('name', v),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Nickname',
              value: data['nickname'] ?? '',
              onChanged: (v) => onChanged('nickname', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Birth',
              value: data['date_of_birth'],
              onChanged: (v) =>
                  onChanged('date_of_birth', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              keyboardType: TextInputType.number,
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
      FormFieldBuilders.textArea(
        label: 'Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Religious Affiliation',
              value: data['religious_affiliation'] ?? '',
              onChanged: (v) => onChanged('religious_affiliation', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Educational Attainment',
              value: data['educational_attainment'] ?? '',
              onChanged: (v) => onChanged('educational_attainment', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Admission',
              value: data['date_of_admission'],
              onChanged: (v) =>
                  onChanged('date_of_admission', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Assessment',
              value: data['date_of_assessment'],
              onChanged: (v) =>
                  onChanged('date_of_assessment', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.datePicker(
        label: 'Date of Report',
        value: data['date_of_report'],
        onChanged: (v) => onChanged('date_of_report', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('II. Reason for Referral'),
      FormFieldBuilders.textArea(
        label: 'Reason for Referral',
        value: data['reason_for_referral'] ?? '',
        onChanged: (v) => onChanged('reason_for_referral', v),
        required: true,
        maxLines: 4,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader(
          'III. Assessment Tools and Other Procedures'),
      FormFieldBuilders.textArea(
        label: 'Assessment Tools Used',
        value: data['assessment_tools'] ?? '',
        onChanged: (v) => onChanged('assessment_tools', v),
        maxLines: 4,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('IV. Results and Discussion'),
      FormFieldBuilders.textArea(
        label: 'Results and Discussion',
        value: data['results_discussion'] ?? '',
        onChanged: (v) => onChanged('results_discussion', v),
        required: true,
        maxLines: 8,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('V. Recommendations / Intervention Plan'),
      FormFieldBuilders.tableHeader(
        [
          'Objectives',
          'Activity',
          'Responsible Person',
          'Time Frame',
          'Outcome'
        ],
        flexValues: [2, 2, 2, 1, 1],
      ),
      ...interventions.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        return FormFieldBuilders.tableRow(
          cells: [
            TextFormField(
              initialValue: item['objectives'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              maxLines: 2,
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['objectives'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['activity'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              maxLines: 2,
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['activity'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['responsible_person'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['responsible_person'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['time_frame'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['time_frame'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['outcome'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['outcome'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
          ],
          flexValues: [2, 2, 2, 1, 1],
          onDelete: () {
            final newItems = List<Map<String, dynamic>>.from(interventions);
            newItems.removeAt(index);
            onChanged('intervention_items', newItems);
          },
        );
      }),
      FormFieldBuilders.addRowButton(() {
        final newItems = List<Map<String, dynamic>>.from(interventions);
        newItems.add({
          'objectives': '',
          'activity': '',
          'responsible_person': '',
          'time_frame': '',
          'outcome': '',
        });
        onChanged('intervention_items', newItems);
      }),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Prepared By',
                  value: data['prepared_by'] ?? '',
                  onChanged: (v) => onChanged('prepared_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Profession',
                  value: data['profession'] ?? '',
                  onChanged: (v) => onChanged('profession', v),
                ),
                FormFieldBuilders.textField(
                  label: 'License No.',
                  value: data['license_no'] ?? '',
                  onChanged: (v) => onChanged('license_no', v),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Noted By',
                  value: data['noted_by'] ?? '',
                  onChanged: (v) => onChanged('noted_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['noted_by_position'] ?? 'Center Head',
                  onChanged: (v) => onChanged('noted_by_position', v),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // PSYCHOMETRICIAN'S REPORT
  static List<Widget> _psychometricianReport(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final interventions = (data['intervention_items'] as List<dynamic>?) ?? [];

    return [
      FormFieldBuilders.sectionHeader('PSYCHOMETRICIAN\'S REPORT'),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Strictly Confidential / Not for Legal Use',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('I. Identifying Data'),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: FormFieldBuilders.textField(
              label: 'Name',
              value: data['name'] ?? '',
              onChanged: (v) => onChanged('name', v),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Nickname',
              value: data['nickname'] ?? '',
              onChanged: (v) => onChanged('nickname', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Birth',
              value: data['date_of_birth'],
              onChanged: (v) =>
                  onChanged('date_of_birth', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['age']?.toString() ?? '',
              keyboardType: TextInputType.number,
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
      FormFieldBuilders.textArea(
        label: 'Address',
        value: data['address'] ?? '',
        onChanged: (v) => onChanged('address', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Religious Affiliation',
              value: data['religious_affiliation'] ?? '',
              onChanged: (v) => onChanged('religious_affiliation', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Educational Attainment',
              value: data['educational_attainment'] ?? '',
              onChanged: (v) => onChanged('educational_attainment', v),
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
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Admission',
              value: data['date_of_admission'],
              onChanged: (v) =>
                  onChanged('date_of_admission', v?.toIso8601String()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'Date of Assessment',
              value: data['date_of_assessment'],
              onChanged: (v) =>
                  onChanged('date_of_assessment', v?.toIso8601String()),
            ),
          ),
        ],
      ),
      FormFieldBuilders.datePicker(
        label: 'Date of Report',
        value: data['date_of_report'],
        onChanged: (v) => onChanged('date_of_report', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('II. Reason for Referral'),
      FormFieldBuilders.textArea(
        label: 'Reason for Referral',
        value: data['reason_for_referral'] ?? '',
        onChanged: (v) => onChanged('reason_for_referral', v),
        required: true,
        maxLines: 4,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Brief History'),
      FormFieldBuilders.textArea(
        label: 'Brief History',
        value: data['brief_history'] ?? '',
        onChanged: (v) => onChanged('brief_history', v),
        maxLines: 6,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Behavioral Observation'),
      FormFieldBuilders.textArea(
        label: 'Behavioral Observation',
        value: data['behavioral_observation'] ?? '',
        onChanged: (v) => onChanged('behavioral_observation', v),
        maxLines: 6,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader(
          'III. Assessment Tools and Other Procedures'),
      FormFieldBuilders.textArea(
        label: 'Assessment Tools Used',
        value: data['assessment_tools'] ?? '',
        onChanged: (v) => onChanged('assessment_tools', v),
        maxLines: 4,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Mental Status Examination'),
      FormFieldBuilders.textArea(
        label: 'Mental Status Examination Results',
        value: data['mental_status_exam'] ?? '',
        onChanged: (v) => onChanged('mental_status_exam', v),
        maxLines: 6,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('IV. Results and Discussion'),
      FormFieldBuilders.textArea(
        label: 'Results and Discussion',
        value: data['results_discussion'] ?? '',
        onChanged: (v) => onChanged('results_discussion', v),
        required: true,
        maxLines: 8,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('V. Recommendations / Intervention Plan'),
      FormFieldBuilders.tableHeader(
        [
          'Objectives',
          'Activity',
          'Responsible Person',
          'Time Frame',
          'Outcome'
        ],
        flexValues: [2, 2, 2, 1, 1],
      ),
      ...interventions.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        return FormFieldBuilders.tableRow(
          cells: [
            TextFormField(
              initialValue: item['objectives'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              maxLines: 2,
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['objectives'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['activity'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              maxLines: 2,
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['activity'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['responsible_person'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['responsible_person'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['time_frame'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['time_frame'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
            TextFormField(
              initialValue: item['outcome'] ?? '',
              decoration: const InputDecoration(
                  isDense: true, border: InputBorder.none),
              onChanged: (v) {
                final newItems = List<Map<String, dynamic>>.from(interventions);
                newItems[index]['outcome'] = v;
                onChanged('intervention_items', newItems);
              },
            ),
          ],
          flexValues: [2, 2, 2, 1, 1],
          onDelete: () {
            final newItems = List<Map<String, dynamic>>.from(interventions);
            newItems.removeAt(index);
            onChanged('intervention_items', newItems);
          },
        );
      }),
      FormFieldBuilders.addRowButton(() {
        final newItems = List<Map<String, dynamic>>.from(interventions);
        newItems.add({
          'objectives': '',
          'activity': '',
          'responsible_person': '',
          'time_frame': '',
          'outcome': '',
        });
        onChanged('intervention_items', newItems);
      }),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Prepared By',
                  value: data['prepared_by'] ?? '',
                  onChanged: (v) => onChanged('prepared_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Profession',
                  value: data['profession'] ?? '',
                  onChanged: (v) => onChanged('profession', v),
                ),
                FormFieldBuilders.textField(
                  label: 'License No.',
                  value: data['license_no'] ?? '',
                  onChanged: (v) => onChanged('license_no', v),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                FormFieldBuilders.textField(
                  label: 'Noted By',
                  value: data['noted_by'] ?? '',
                  onChanged: (v) => onChanged('noted_by', v),
                ),
                FormFieldBuilders.textField(
                  label: 'Position',
                  value: data['noted_by_position'] ?? 'Center Head',
                  onChanged: (v) => onChanged('noted_by_position', v),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
