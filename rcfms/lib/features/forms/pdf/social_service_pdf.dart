import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

import '../templates/form_templates.dart';
import 'pdf_styles.dart';

/// Social Service PDF Templates
class SocialServicePdf {
  SocialServicePdf._();

  static List<pw.Page> buildPages({
    required FormTemplate template,
    required Map<String, dynamic> data,
    required String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  }) {
    switch (template.templateType) {
      case 'pre_admission_checklist':
        return _buildPreAdmissionChecklist(data, residentName, logoBytes);
      case 'requirements_checklist':
        return _buildRequirementsChecklist(data, residentName, logoBytes);
      case 'general_intake_sheet':
        return _buildGeneralIntakeSheet(data, residentName, caseNumber, logoBytes);
      case 'admission_case_conference':
      case 'case_conference':
        return _buildCaseConference(data, residentName, template.name, logoBytes);
      case 'clients_contract':
        return _buildClientsContract(data, residentName, logoBytes);
      case 'admission_slip':
        return _buildAdmissionSlip(data, residentName, caseNumber, logoBytes);
      case 'progress_notes':
        return _buildProgressNotes(data, residentName, logoBytes);
      case 'running_notes':
        return _buildRunningNotes(data, residentName, logoBytes);
      case 'intervention_plan':
        return _buildInterventionPlan(data, residentName, caseNumber, logoBytes);
      case 'social_case_study':
        return _buildSocialCaseStudy(data, residentName, caseNumber, logoBytes);
      case 'termination_report':
        return _buildTerminationReport(data, residentName, logoBytes);
      case 'closing_summary':
        return _buildClosingSummary(data, residentName, caseNumber, logoBytes);
      case 'quarterly_narrative':
        return _buildQuarterlyNarrative(data, residentName, logoBytes);
      default:
        return [_buildPlaceholder()];
    }
  }

  static pw.Page _buildPlaceholder() {
    return pw.Page(
      pageFormat: PdfStyles.pageFormat,
      build: (context) => pw.Center(child: pw.Text('Form template not available')),
    );
  }

  // ============ PRE-ADMISSION CHECKLIST ============
  static List<pw.Page> _buildPreAdmissionChecklist(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('PRE-ADMISSION CHECKLIST'),
              
              // Client info table
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                children: [
                  _infoRow('Name', data['name'] ?? residentName, 'Date', PdfStyles.formatDate(data['date'])),
                  _infoRow('Age', data['age']?.toString() ?? '', 'Category', data['category'] ?? ''),
                  _singleRow('Place of Birth', data['place_of_birth'] ?? ''),
                  _singleRow('Referred by', data['referred_by'] ?? ''),
                ],
              ),
              pw.SizedBox(height: 16),
              
              // Category checklist
              _buildCategoryTable(data),
              
              pw.SizedBox(height: 16),
              PdfStyles.labeledTextArea('Remarks', data['remarks'], minHeight: 80),
            ],
          );
        },
      ),
    ];
  }

  // ============ REQUIREMENTS CHECKLIST ============
  static List<pw.Page> _buildRequirementsChecklist(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    final requirements = [
      ('REFERRAL LETTER', 'referral_letter'),
      ('SOCIAL CASE STUDY REPORT', 'social_case_study_report'),
      ('CHEST X-RAY', 'chest_xray'),
      ('MEDICAL CERTIFICATE', 'medical_certificate'),
      ('LABORATORY (LATEST)', 'laboratory_latest'),
      ('BLOOD CHEMISTRY (FBS, SGPT, SGOT, URIC, CREATININE, CHOLESTEROL, BUN, ELECTROLYTES)', 'blood_chemistry'),
      ('URINALYSIS', 'urinalysis'),
      ('STOOL', 'stool_exam'),
      ('ULTRASOUND (IF NEEDED)', 'ultrasound'),
      ('PSYCHOLOGICAL EVALUATION', 'psychological_evaluation'),
      ('VACCINATION CARD', 'vaccination_card'),
      ('RT-PCR / ANTIGEN RESULT', 'rt_pcr_antigen'),
      ('OSCA ID', 'osca_id'),
    ];

    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('REQUIREMENTS CHECKLIST'),
              
              // Client info
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Name', data['name'] ?? residentName)),
                pw.SizedBox(width: 20),
                pw.SizedBox(width: 150, child: PdfStyles.labelWithUnderline('Date', PdfStyles.formatDate(data['checklist_date']))),
              ]),
              pw.SizedBox(height: 4),
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Age', data['age']?.toString() ?? '')),
                pw.SizedBox(width: 20),
                pw.SizedBox(width: 150, child: PdfStyles.labelWithUnderline('Category', data['category'] ?? '')),
              ]),
              pw.SizedBox(height: 4),
              PdfStyles.labelWithUnderline('Place of Birth', data['place_of_birth'] ?? ''),
              PdfStyles.labelWithUnderline('Address', data['address'] ?? ''),
              PdfStyles.labelWithUnderline('Referred by', data['referred_by'] ?? ''),
              pw.SizedBox(height: 12),
              
              // Requirements table
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FixedColumnWidth(40),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('REQUIREMENTS', isHeader: true),
                      _cell('YES', isHeader: true),
                      _cell('NO', isHeader: true),
                      _cell('REMARKS', isHeader: true),
                    ],
                  ),
                  ...requirements.map((req) => pw.TableRow(
                    children: [
                      _cell(req.$1),
                      _cell(data['req_${req.$2}_yes'] == true ? '✓' : '', center: true),
                      _cell(data['req_${req.$2}_yes'] == false ? '✓' : '', center: true),
                      _cell(data['req_${req.$2}_remarks'] ?? ''),
                    ],
                  )),
                ],
              ),
              
              pw.Spacer(),
              
              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Endorsed by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureLine(data['endorsed_by'] ?? '', width: 150),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Received by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureLine(data['received_by'] ?? '', width: 150),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ GENERAL INTAKE SHEET ============
  static List<pw.Page> _buildGeneralIntakeSheet(
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('GENERAL INTAKE SHEET'),
              
              // Header info
              pw.Row(
                children: [
                  pw.Expanded(child: PdfStyles.labelWithUnderline('Case No', caseNumber ?? data['case_no'] ?? '')),
                  pw.SizedBox(width: 20),
                  pw.SizedBox(width: 150, child: PdfStyles.labelWithUnderline('Date', PdfStyles.formatDate(data['intake_date']))),
                ],
              ),
              pw.Row(
                children: [
                  PdfStyles.checkbox(data['case_type'] == 'New', label: 'New'),
                  pw.SizedBox(width: 20),
                  PdfStyles.checkbox(data['case_type'] == 'Re-opened', label: 'Re-opened'),
                ],
              ),
              
              PdfStyles.sectionHeader('IDENTIFYING INFORMATION'),
              PdfStyles.labelWithUnderline('Name of Applicant', data['applicant_name'] ?? residentName),
              PdfStyles.labelWithUnderline('Address', data['applicant_address'] ?? ''),
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Birthplace', data['birthplace'] ?? '')),
                pw.SizedBox(width: 20),
                pw.Expanded(child: PdfStyles.labelWithUnderline('Birthday', PdfStyles.formatDate(data['birthday']))),
              ]),
              PdfStyles.labelWithUnderline('Name of Nearest Relative', data['nearest_relative_name'] ?? ''),
              PdfStyles.labelWithUnderline('Address of Nearest Relative', data['nearest_relative_address'] ?? ''),
              PdfStyles.labelWithUnderline('If disabled, nature of disability', data['disability_nature'] ?? ''),
              PdfStyles.labelWithUnderline('Source of Referral', data['referral_source'] ?? ''),
              
              PdfStyles.sectionHeader('ASSESSMENT'),
              PdfStyles.labeledTextArea('PROBLEM PRESENTED', data['problem_presented'], minHeight: 60),
              pw.SizedBox(height: 8),
              PdfStyles.labeledTextArea('Initial Assessment', data['initial_assessment'], minHeight: 50),
              pw.SizedBox(height: 8),
              PdfStyles.labeledTextArea('ACTION TAKEN', data['action_taken'], minHeight: 40),
              pw.SizedBox(height: 8),
              PdfStyles.labeledTextArea('ASSESSMENT AND RECOMMENDATION', data['assessment_recommendation'], minHeight: 40),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 180,
                        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))),
                      ),
                      pw.Text('(Signature/Thumbmark of Applicant)', style: PdfStyles.smallStyle),
                    ],
                  ),
                  PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ CASE CONFERENCE ============
  static List<pw.Page> _buildCaseConference(
    Map<String, dynamic> data,
    String residentName,
    String title,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle(title.toUpperCase()),
              
              // Client info
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                children: [
                  _infoRow('Name of Client', data['client_name'] ?? residentName, 'Age', data['client_age']?.toString() ?? ''),
                  _infoRow('Date Admitted', PdfStyles.formatDate(data['date_admitted']), 'Case Category', data['case_category'] ?? ''),
                  _singleRow('Condition', data['condition'] ?? ''),
                  _infoRow('Venue', data['venue'] ?? '', 'Date of Conference', PdfStyles.formatDate(data['conference_date'])),
                  _infoRow('Date Submitted', PdfStyles.formatDate(data['date_submitted']), 'Time Allotted', data['time_allotted'] ?? ''),
                  _singleRow('Present', data['attendees'] ?? ''),
                ],
              ),
              pw.SizedBox(height: 12),
              
              PdfStyles.labeledTextArea('Objective', data['objective'], minHeight: 50),
              pw.SizedBox(height: 12),
              
              // Discussions table
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(1)},
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('Discussions', isHeader: true),
                      _cell('Agreement Reached/Recommendations', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cellMinHeight(data['discussions'] ?? '', 120),
                      _cellMinHeight(data['agreement_recommendations'] ?? '', 120),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Noted by:', style: PdfStyles.normalStyle),
                  PdfStyles.signatureBlock(
                    role: 'Center Head/SWO II',
                    name: 'CANDELARIA C. TINGSON, RSW',
                    width: 200,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ CLIENT'S CONTRACT ============
  static List<pw.Page> _buildClientsContract(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle("CLIENT'S CONTRACT"),
              
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: PdfStyles.normalStyle,
                  children: [
                    const pw.TextSpan(text: 'I am '),
                    pw.TextSpan(text: data['client_name'] ?? residentName, style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: ', of legal age, status '),
                    pw.TextSpan(text: data['status'] ?? '_______', style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: ', Filipino and a resident of '),
                    pw.TextSpan(text: data['address'] ?? '_______________________', style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: '. I promise to take custody of client '),
                    pw.TextSpan(text: data['custodian_name'] ?? '________________', style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: ', age ______, admitted on '),
                    pw.TextSpan(text: PdfStyles.formatDate(data['date_admitted']), style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: ' referred by '),
                    pw.TextSpan(text: data['referred_by'] ?? '_____________', style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: ' after 6 to 1 year of staying in the center based on the following agreement:'),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              
              _bulletPoint('Provide Parenting Capability Assessment Reports (PCAR) to respective LGU, FOs and NGO support services for family preparation for reunification or clients\' other appropriate alternative placement.'),
              _bulletPoint('It provides rehabilitation services to help people improve or maintain their physical, social, emotional, and mental health.'),
              _bulletPoint('Conduct activities to harness clients\' vocational skills geared towards enhancing capability and capacity for productivity, if applicable.'),
              _bulletPoint('Facilitate the senior citizen\'s eventual integration into his or her own family.'),
              _bulletPoint('Provide opportunities to enable older people\'s participation in community affairs, social, recreational, and cultural activities.'),
              _bulletPoint('Deliver or provide appropriate rehabilitative services based on the treatment plan.'),
              _bulletPoint('Family members and relatives are welcome to visit the center from 8:00 a.m. to 5:00 p.m. (Monday-Friday).'),
              _bulletPoint('In case of an emergency or any updates on the client, the family/relatives of the referring party will be kept updated.'),
              _bulletPoint('Constant communication and monitoring will be maintained by the family members, relatives, and partners.'),
              _bulletPoint('In the event of the death of the client, any documents or valuables received based on the record shall be turned over to the family/relatives.'),
              
              pw.SizedBox(height: 12),
              pw.Text(
                'This ${data['contract_date'] != null ? PdfStyles.formatDateFull(data['contract_date']) : '______day of _______, _____'} in Tagum City, Philippines, is signed.',
                style: PdfStyles.normalStyle,
                textAlign: pw.TextAlign.justify,
              ),
              
              pw.Spacer(),
              
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: PdfStyles.signatureBlock(role: "Client's Relative", width: 180),
              ),
              pw.SizedBox(height: 12),
              
              pw.Center(child: pw.Text('SIGNED IN THE PRESENCE OF:', style: PdfStyles.subHeaderStyle)),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Witness:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureLine(data['witness_1'] ?? '', width: 150),
                      pw.SizedBox(height: 8),
                      PdfStyles.signatureLine(data['witness_2'] ?? '', width: 150),
                      pw.Text('C/MSWDO', style: PdfStyles.smallStyle),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Noted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(
                        role: 'Center Head/SWO III',
                        name: 'CANDELARIA C. TINGSON, RSW',
                        width: 200,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ ADMISSION SLIP ============
  static List<pw.Page> _buildAdmissionSlip(
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('ADMISSION SLIP'),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Date: ${PdfStyles.formatDate(data['admission_date'])}', style: PdfStyles.normalStyle),
                  pw.SizedBox(width: 40),
                  pw.Text('Time: ${data['admission_time'] ?? ''}', style: PdfStyles.normalStyle),
                ],
              ),
              pw.Center(child: pw.Text('Case Control no. ${caseNumber ?? data['case_control_no'] ?? ''}', style: PdfStyles.normalStyle)),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                children: [
                  _singleRow('Name of Client', data['client_name'] ?? residentName),
                  _singleRow('Age', data['client_age']?.toString() ?? ''),
                  _singleRow('Complete Address', data['complete_address'] ?? ''),
                  _infoRow('Civil Status', data['civil_status'] ?? '', 'Religion', data['religion'] ?? ''),
                  _singleRow('Educational Attain.', data['educational_attainment'] ?? ''),
                  _singleRow('Referred by', data['referred_by'] ?? ''),
                  _singleRow('Complete address of Referring Party', data['referring_party_address'] ?? ''),
                  _singleRow('Name and address of the nearest relative', data['nearest_relative'] ?? ''),
                ],
              ),
              pw.SizedBox(height: 12),
              
              PdfStyles.labeledTextArea('Medical Findings/Clearance', data['medical_findings'], minHeight: 60),
              
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: PdfStyles.labelWithUnderline('Assigned to Room', data['assigned_room'] ?? '')),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Checked by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureLine('Medical Staff', width: 120),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Admitted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 150),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Approved by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Center Head/SWO III', width: 150),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('Conformed: ___________________________', style: PdfStyles.normalStyle),
            ],
          );
        },
      ),
    ];
  }

  // ============ PROGRESS NOTES ============
  static List<pw.Page> _buildProgressNotes(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('PROGRESS NOTES'),
              
              PdfStyles.labelWithUnderline('Name of Client', data['client_name'] ?? residentName),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {0: const pw.FixedColumnWidth(80), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2)},
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('Date', isHeader: true),
                      _cell('Observations', isHeader: true),
                      _cell('Supervisory Remarks', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cellMinHeight(PdfStyles.formatDate(data['progress_date']), 300),
                      _cellMinHeight(data['observations'] ?? '', 300),
                      _cellMinHeight(data['supervisory_remarks'] ?? '', 300),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: PdfStyles.signatureBlock(role: 'SOCIAL WORKER', width: 180),
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ RUNNING NOTES ============
  static List<pw.Page> _buildRunningNotes(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('RUNNING NOTES'),
              
              PdfStyles.labelWithUnderline('Name of Client', data['client_name'] ?? residentName),
              pw.SizedBox(height: 12),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {0: const pw.FixedColumnWidth(80), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2)},
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('Date', isHeader: true),
                      _cell('Notes / Observations', isHeader: true),
                      _cell('Supervisory Remarks', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cellMinHeight(PdfStyles.formatDate(data['running_date']), 350),
                      _cellMinHeight(data['notes'] ?? '', 350),
                      _cellMinHeight(data['supervisory_remarks'] ?? '', 350),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: PdfStyles.signatureBlock(role: 'SOCIAL WORKER', width: 180),
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ INTERVENTION PLAN ============
  static List<pw.Page> _buildInterventionPlan(
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('MODIFIED INTERVENTION PLAN'),
              
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Date Prepared: ${PdfStyles.formatDate(data['date_prepared'])}', style: PdfStyles.normalStyle),
              ),
              
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Name of Client', data['client_name'] ?? residentName)),
                pw.SizedBox(width: 20),
                pw.SizedBox(width: 150, child: PdfStyles.labelWithUnderline('Case Control No.', caseNumber ?? data['case_control_no'] ?? '')),
              ]),
              pw.SizedBox(height: 12),
              
              pw.RichText(
                text: pw.TextSpan(
                  style: PdfStyles.normalStyle,
                  children: [
                    const pw.TextSpan(text: 'In three (3) months time ('),
                    pw.TextSpan(text: '                    ', style: PdfStyles.subHeaderStyle),
                    const pw.TextSpan(text: '), client\'s social functioning will be sustained.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              
              // Intervention table
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('OBJECTIVES', isHeader: true),
                      _cell('ACTIVITIES', isHeader: true),
                      _cell('TIME FRAME', isHeader: true),
                      _cell('RESPONSIBLE UNIT / PERSON', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cellMinHeight(data['objectives'] ?? '', 150),
                      _cellMinHeight(data['activities'] ?? '', 150),
                      _cellMinHeight(data['time_frame'] ?? '', 150),
                      _cellMinHeight(data['responsible_person'] ?? '', 150),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Confirmed by Client:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureLine('', width: 180),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Noted by:', style: PdfStyles.normalStyle),
                  PdfStyles.signatureBlock(
                    role: 'Center Head / SWO II',
                    name: 'CANDELARIA C. TINGSON, RSW',
                    width: 200,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ SOCIAL CASE STUDY REPORT ============
  static List<pw.Page> _buildSocialCaseStudy(
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  ) {
    // Multi-page document
    return [
      pw.MultiPage(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        header: (context) => context.pageNumber == 1 
            ? PdfStyles.buildDswdHeader(logoBytes: logoBytes, compact: true)
            : pw.SizedBox(),
        footer: (context) => PdfStyles.pageFooter(context),
        build: (context) => [
          if (context.pageNumber == 1) ...[
            PdfStyles.formTitle('UPDATED SOCIAL CASE STUDY REPORT'),
            
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${PdfStyles.formatDate(data['report_date'])}', style: PdfStyles.normalStyle),
                    pw.Text('Year Admitted: ${data['year_admitted'] ?? ''}', style: PdfStyles.normalStyle),
                    pw.Text('Case No. ${caseNumber ?? data['case_no'] ?? ''}', style: PdfStyles.normalStyle),
                    pw.Text('Length of Stay: ${data['length_of_stay'] ?? ''}', style: PdfStyles.normalStyle),
                    pw.Text('Older Person Category: ${data['category'] ?? ''}', style: PdfStyles.normalStyle),
                  ],
                ),
              ],
            ),
          ],
          
          PdfStyles.sectionHeader('Identifying Data'),
          pw.Row(children: [
            pw.Expanded(child: PdfStyles.labelWithUnderline('Name', data['name'] ?? residentName)),
            pw.SizedBox(width: 20),
            pw.SizedBox(width: 80, child: PdfStyles.labelWithUnderline('Age', data['age']?.toString() ?? '')),
          ]),
          pw.Row(children: [
            pw.Expanded(child: PdfStyles.labelWithUnderline('Sex', data['sex'] ?? '')),
            pw.SizedBox(width: 20),
            pw.Expanded(child: PdfStyles.labelWithUnderline('Civil Status', data['civil_status'] ?? '')),
          ]),
          pw.Row(children: [
            pw.Expanded(child: PdfStyles.labelWithUnderline('Birth Date', PdfStyles.formatDate(data['birth_date']))),
            pw.SizedBox(width: 20),
            pw.Expanded(child: PdfStyles.labelWithUnderline('Birth Place', data['birth_place'] ?? '')),
          ]),
          PdfStyles.labelWithUnderline('Educational Attainment', data['educational_attainment'] ?? ''),
          PdfStyles.labelWithUnderline('Provincial/City Address', data['address'] ?? ''),
          PdfStyles.labelWithUnderline('Source of Referral', data['referral_source'] ?? ''),
          PdfStyles.labelWithUnderline('Name of the Referring Party', data['referring_party'] ?? ''),
          
          PdfStyles.sectionHeader('Family Composition'),
          PdfStyles.textArea(data['family_composition'], minHeight: 60),
          
          PdfStyles.sectionHeader('Problem Presented'),
          PdfStyles.textArea(data['problem_presented'], minHeight: 60),
          
          PdfStyles.sectionHeader('Findings'),
          PdfStyles.textArea(data['findings'], minHeight: 60),
          
          PdfStyles.sectionHeader('History'),
          PdfStyles.textArea(data['history'], minHeight: 60),
          
          PdfStyles.sectionHeader('Medical and Nutritional Needs'),
          PdfStyles.textArea(data['medical_nutritional_needs'], minHeight: 50),
          
          PdfStyles.sectionHeader('Present Status'),
          PdfStyles.textArea(data['present_status'], minHeight: 50),
          
          PdfStyles.sectionHeader('Action Taken/Service Provided'),
          PdfStyles.textArea(data['action_taken'], minHeight: 50),
          
          PdfStyles.sectionHeader('Assessment and Recommendation'),
          PdfStyles.textArea(data['assessment_recommendation'], minHeight: 50),
          
          PdfStyles.sectionHeader('Intervention Plan'),
          PdfStyles.textArea(data['intervention_plan'], minHeight: 50),
          
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                  PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Noted by:', style: PdfStyles.normalStyle),
              PdfStyles.signatureBlock(role: 'Center Head/SWO II', width: 180),
            ],
          ),
        ],
      ),
    ];
  }

  // ============ TERMINATION REPORT ============
  static List<pw.Page> _buildTerminationReport(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('TERMINATION REPORT'),
              
              pw.Center(child: pw.Text('Date: ${PdfStyles.formatDate(data['termination_date'])}', style: PdfStyles.normalStyle)),
              pw.SizedBox(height: 12),
              
              PdfStyles.labeledTextArea('Identifying Information', data['client_name'] ?? residentName, minHeight: 40),
              PdfStyles.labeledTextArea('Reason for client\'s admission at the Home for the Aged', data['admission_reason'], minHeight: 60),
              PdfStyles.labeledTextArea('Intervention provided by the HA', data['intervention_provided'], minHeight: 60),
              PdfStyles.labeledTextArea('Social Functioning of the resident upon discharge', data['social_functioning'], minHeight: 60),
              PdfStyles.labeledTextArea('Why the case is being closed', data['closing_reason'], minHeight: 60),
              PdfStyles.labeledTextArea('Recommendations', data['recommendations'], minHeight: 50),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared and submitted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Noted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Center Head/SWO III', width: 180),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Recommending Approval:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Protective Services Division Chief', width: 200),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Approved by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Regional Director', width: 150),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ CLOSING SUMMARY ============
  static List<pw.Page> _buildClosingSummary(
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('CLOSING SUMMARY'),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${PdfStyles.formatDate(data['closing_date'])}', style: PdfStyles.normalStyle),
                      pw.Text('Case No. ${caseNumber ?? data['case_no'] ?? ''}', style: PdfStyles.normalStyle),
                    ],
                  ),
                ],
              ),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                children: [
                  _singleRow('Name', data['name'] ?? residentName),
                  _infoRow('Age', data['age']?.toString() ?? '', 'Gender', data['gender'] ?? ''),
                  _singleRow('Address', data['address'] ?? ''),
                  _singleRow('Source of Referral', data['referral_source'] ?? ''),
                  _singleRow('Address of referring Party', data['referring_party_address'] ?? ''),
                  _infoRow('Date Admitted', PdfStyles.formatDate(data['date_admitted']), 'Date of Discharge', PdfStyles.formatDate(data['date_discharged'])),
                ],
              ),
              pw.SizedBox(height: 12),
              
              PdfStyles.labeledTextArea('SUMMARY OF CASE', data['case_summary'], minHeight: 200),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 180),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Approved by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Center Head/SWO II', width: 180),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ QUARTERLY NARRATIVE REPORT ============
  static List<pw.Page> _buildQuarterlyNarrative(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    return [
      pw.Page(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfStyles.buildDswdHeader(logoBytes: logoBytes),
              PdfStyles.formTitle('${data['quarter'] ?? '1ST'} QUARTER PROGRESS NARRATIVE REPORT'),
              
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Name of client', data['client_name'] ?? residentName)),
                pw.SizedBox(width: 20),
                pw.SizedBox(width: 150, child: PdfStyles.labelWithUnderline('Date', PdfStyles.formatDate(data['report_date']))),
              ]),
              pw.SizedBox(height: 12),
              
              pw.Text('SOCIAL SERVICE', style: PdfStyles.subHeaderStyle),
              PdfStyles.textArea(data['social_service'], minHeight: 50),
              pw.SizedBox(height: 8),
              
              pw.Text('MEDICAL SERVICE', style: PdfStyles.subHeaderStyle),
              PdfStyles.textArea(data['medical_service'], minHeight: 50),
              pw.SizedBox(height: 8),
              
              pw.Text('PSYCH SERVICE', style: PdfStyles.subHeaderStyle),
              PdfStyles.textArea(data['psych_service'], minHeight: 50),
              pw.SizedBox(height: 8),
              
              pw.Text('HOMELIFE SERVICE', style: PdfStyles.subHeaderStyle),
              PdfStyles.textArea(data['homelife_service'], minHeight: 50),
              pw.SizedBox(height: 8),
              
              pw.Text('PSD SERVICE', style: PdfStyles.subHeaderStyle),
              PdfStyles.textArea(data['psd_service'], minHeight: 50),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Social Worker', width: 150),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Noted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(role: 'Center Head/SWO II', width: 150),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ HELPER METHODS ============
  
  static pw.Widget _bulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4, left: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: PdfStyles.normalStyle),
          pw.Expanded(
            child: pw.Text(text, style: PdfStyles.normalStyle, textAlign: pw.TextAlign.justify),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryTable(Map<String, dynamic> data) {
    final categories = ['Abandoned', 'Neglected', 'Unattached', 'Homeless'];
    final ageRanges = ['60 to below 71', '71 to below 80', '80 and above', '60 and below'];
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FixedColumnWidth(30),
        4: const pw.FixedColumnWidth(30),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
          children: [
            _cell('', isHeader: true),
            _cell('Case Category', isHeader: true),
            _cell('SENIOR CITIZENS', isHeader: true),
            _cell('M', isHeader: true),
            _cell('F', isHeader: true),
          ],
        ),
        ...categories.asMap().entries.expand((entry) {
          final idx = entry.key;
          final category = entry.value;
          return [
            pw.TableRow(children: [
              _cell('${idx + 1}.'),
              _cell(category, isHeader: true),
              _cell(''),
              _cell(''),
              _cell(''),
            ]),
            ...ageRanges.map((range) => pw.TableRow(children: [
              _cell(''),
              _cell(''),
              _cell(range),
              _cell(''),
              _cell(''),
            ])),
          ];
        }),
      ],
    );
  }

  static pw.TableRow _infoRow(String label1, String value1, String label2, String value2) {
    return pw.TableRow(
      children: [
        _cell('$label1:', isHeader: true),
        _cell(value1),
        _cell('$label2:', isHeader: true),
        _cell(value2),
      ],
    );
  }

  static pw.TableRow _singleRow(String label, String value) {
    return pw.TableRow(
      children: [
        _cell('$label:', isHeader: true),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(value, style: PdfStyles.normalStyle),
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false, bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: isHeader ? PdfStyles.labelStyle : PdfStyles.normalStyle,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _cellMinHeight(String text, double minHeight) {
    return pw.Container(
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: PdfStyles.normalStyle),
    );
  }
}
