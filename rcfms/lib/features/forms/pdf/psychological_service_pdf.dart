import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../templates/form_templates.dart';
import 'pdf_styles.dart';

/// Psychological Service PDF Templates
class PsychologicalServicePdf {
  PsychologicalServicePdf._();

  static List<pw.Page> buildPages({
    required FormTemplate template,
    required Map<String, dynamic> data,
    required String residentName,
    String? caseNumber,
    Uint8List? logoBytes,
  }) {
    switch (template.templateType) {
      case 'progress_notes':
        return _buildProgressNotes(data, residentName, logoBytes);
      case 'group_sessions':
        return _buildGroupSessionsReport(data, residentName, logoBytes);
      case 'individual_sessions':
        return _buildIndividualSessionsReport(data, residentName, logoBytes);
      case 'inter_service_referral':
        return _buildInterServiceReferral(data, residentName, logoBytes);
      case 'initial_assessment':
        return _buildInitialAssessment(data, residentName, logoBytes);
      case 'psychometrician_report':
        return _buildPsychometricianReport(data, residentName, logoBytes);
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
              
              pw.Row(children: [
                pw.Expanded(
                  child: PdfStyles.labelWithUnderline('Name of Client', data['client_name'] ?? residentName),
                ),
                pw.SizedBox(width: 20),
                pw.SizedBox(
                  width: 200,
                  child: PdfStyles.labelWithUnderline(
                    'Coverage',
                    '${data['coverage_month'] ?? 'January'}, ${data['coverage_year'] ?? DateTime.now().year}',
                  ),
                ),
              ]),
              PdfStyles.labelWithUnderline('Date Submitted', PdfStyles.formatDate(data['date_submitted'])),
              pw.SizedBox(height: 12),
              
              // Progress table
              pw.Table(
                border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                    children: [
                      _cell('Observations / Findings', isHeader: true),
                      _cell('Supervisory Remarks', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        constraints: const pw.BoxConstraints(minHeight: 200),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Mental Health Status:', style: PdfStyles.subHeaderStyle),
                            pw.Text(data['mental_health_status'] ?? '', style: PdfStyles.normalStyle),
                            pw.SizedBox(height: 12),
                            pw.Text('Activities of Daily Living (ADL):', style: PdfStyles.subHeaderStyle),
                            pw.Text(data['adl_status'] ?? '', style: PdfStyles.normalStyle),
                            pw.SizedBox(height: 12),
                            pw.Text('Socio-Emotional (Demonstrates):', style: PdfStyles.subHeaderStyle),
                            pw.Text(data['socio_emotional'] ?? '', style: PdfStyles.normalStyle),
                          ],
                        ),
                      ),
                      _cellMinHeight(data['supervisory_remarks'] ?? '', 200),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        constraints: const pw.BoxConstraints(minHeight: 80),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('WAYS FORWARD:', style: PdfStyles.subHeaderStyle),
                            pw.Text(data['ways_forward'] ?? '', style: PdfStyles.normalStyle),
                          ],
                        ),
                      ),
                      _cellMinHeight('', 80),
                    ],
                  ),
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
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(
                        role: 'Psychometrician',
                        name: data['prepared_by'],
                        licenseNo: data['license_no'],
                        width: 200,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Noted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(
                        role: 'Center Head',
                        name: data['noted_by'],
                        width: 180,
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

  // ============ GROUP SESSIONS REPORT ============
  static List<pw.Page> _buildGroupSessionsReport(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    final participants = (data['participant_details'] as List<dynamic>?) ?? [];
    
    return [
      pw.MultiPage(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        header: (context) => context.pageNumber == 1
            ? PdfStyles.buildDswdHeader(logoBytes: logoBytes, compact: true)
            : pw.SizedBox(),
        footer: (context) => PdfStyles.pageFooter(context),
        build: (context) => [
          PdfStyles.formTitle('GROUP SESSIONS REPORT'),
          PdfStyles.confidentialityNotice(),
          pw.SizedBox(height: 12),
          
          // Session type
          pw.Row(
            children: [
              PdfStyles.checkbox(data['type_referral'] ?? false, label: 'By Referral'),
              pw.SizedBox(width: 30),
              PdfStyles.checkbox(data['type_walkin'] ?? false, label: 'Walk-in'),
              pw.SizedBox(width: 30),
              PdfStyles.checkbox(data['type_as_needed'] ?? false, label: 'As Need Arises'),
            ],
          ),
          pw.SizedBox(height: 12),
          
          pw.Row(children: [
            pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Session', PdfStyles.formatDate(data['session_date']))),
            pw.SizedBox(width: 20),
            pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Report', PdfStyles.formatDate(data['report_date']))),
          ]),
          
          PdfStyles.sectionHeader('REASON FOR SESSION'),
          PdfStyles.textArea(data['reason_for_session'], minHeight: 40),
          
          PdfStyles.sectionHeader('PARTICIPANTS'),
          PdfStyles.textArea(data['participants'], minHeight: 40),
          
          PdfStyles.sectionHeader('OBJECTIVES OF THE SESSION'),
          PdfStyles.textArea(data['objectives'], minHeight: 40),
          
          PdfStyles.sectionHeader('SESSION NARRATIVE'),
          PdfStyles.textArea(data['session_narrative'], minHeight: 80),
          
          PdfStyles.sectionHeader('AGREEMENTS/LESSONS IMPARTED'),
          
          // Participant-specific table if available
          if (participants.isNotEmpty) ...[
            pw.Table(
              border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
                  children: [
                    _cell('Participant', isHeader: true),
                    _cell('Challenges', isHeader: true),
                    _cell('Agreements/Lessons Imparted', isHeader: true),
                  ],
                ),
                ...participants.map((p) {
                  final participant = p as Map<String, dynamic>;
                  return pw.TableRow(
                    children: [
                      _cell(participant['name'] ?? ''),
                      _cell(participant['challenges'] ?? ''),
                      _cell(participant['agreements'] ?? ''),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
          
          PdfStyles.textArea(data['general_agreements'], minHeight: 50),
          
          PdfStyles.sectionHeader('RECOMMENDATIONS'),
          PdfStyles.textArea(data['recommendations'], minHeight: 60),
          
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                  PdfStyles.signatureBlock(
                    role: 'Psychometrician',
                    name: data['prepared_by'],
                    licenseNo: data['license_no'],
                    width: 200,
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Noted by:', style: PdfStyles.normalStyle),
                  PdfStyles.signatureBlock(
                    role: 'Center Head',
                    name: data['noted_by'],
                    width: 180,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // ============ INDIVIDUAL SESSIONS REPORT ============
  static List<pw.Page> _buildIndividualSessionsReport(
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
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Department of Social Welfare and Development XI', style: PdfStyles.headerStyle),
                    pw.Text('Home for the Aged', style: PdfStyles.headerStyle),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              PdfStyles.formTitle('INDIVIDUAL SESSIONS REPORT'),
              PdfStyles.confidentialityNotice(),
              pw.SizedBox(height: 12),
              
              // Session type
              pw.Row(
                children: [
                  PdfStyles.checkbox(data['type_referral'] ?? false, label: 'By Referral'),
                  pw.SizedBox(width: 30),
                  PdfStyles.checkbox(data['type_walkin'] ?? false, label: 'Walk-in'),
                  pw.SizedBox(width: 30),
                  PdfStyles.checkbox(data['type_as_needed'] ?? false, label: 'As Need Arises'),
                ],
              ),
              pw.SizedBox(height: 12),
              
              PdfStyles.labelWithUnderline('Client Name', data['client_name'] ?? residentName),
              pw.Row(children: [
                pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Session', PdfStyles.formatDate(data['session_date']))),
                pw.SizedBox(width: 20),
                pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Report', PdfStyles.formatDate(data['report_date']))),
              ]),
              
              PdfStyles.sectionHeader('REASON FOR SESSION'),
              PdfStyles.textArea(data['reason_for_session'], minHeight: 40),
              
              PdfStyles.sectionHeader('OBJECTIVES OF THE SESSION'),
              PdfStyles.textArea(data['objectives'], minHeight: 40),
              
              PdfStyles.sectionHeader('SESSION NARRATIVE'),
              PdfStyles.textArea(data['session_narrative'], minHeight: 100),
              
              PdfStyles.sectionHeader('AGREEMENTS/LESSONS IMPARTED'),
              PdfStyles.textArea(data['agreements'], minHeight: 50),
              
              PdfStyles.sectionHeader('RECOMMENDATIONS'),
              PdfStyles.textArea(data['recommendations'], minHeight: 50),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Prepared by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(
                        role: 'Psychometrician',
                        name: data['prepared_by'] ?? 'VIEL JAN W. APOG, RPm',
                        licenseNo: data['license_no'] ?? '0004383',
                        width: 200,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Noted by:', style: PdfStyles.normalStyle),
                      PdfStyles.signatureBlock(
                        role: 'Center Head',
                        name: data['noted_by'] ?? 'CANDELARIA C. TINGSON, RSW',
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

  // ============ INTER-SERVICE REFERRAL ============
  static List<pw.Page> _buildInterServiceReferral(
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
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Department of Social Welfare and Development – XI', style: PdfStyles.headerStyle),
                    pw.Text('Home for the Aged', style: PdfStyles.normalStyle),
                    pw.Text('Visayan Village, Tagum City, Davao del Norte', style: PdfStyles.smallStyle),
                    pw.SizedBox(height: 4),
                    pw.Text('Psychological Service', style: PdfStyles.headerStyle),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              PdfStyles.formTitle('REFERRAL FORM'),
              
              PdfStyles.labelWithUnderline('Date of Referral', PdfStyles.formatDate(data['referral_date'])),
              pw.SizedBox(height: 12),
              
              // Client info
              pw.Row(children: [
                pw.Expanded(
                  flex: 2,
                  child: PdfStyles.labelWithUnderline('Name', data['client_name'] ?? residentName),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: PdfStyles.labelWithUnderline('Nickname', data['nickname'] ?? ''),
                ),
              ]),
              pw.Row(children: [
                pw.Expanded(
                  child: PdfStyles.labelWithUnderline('Date of Birth', PdfStyles.formatDate(data['date_of_birth'])),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: PdfStyles.labelWithUnderline('Age', data['age']?.toString() ?? ''),
                ),
              ]),
              PdfStyles.labelWithUnderline('Ward/Room', data['ward_room'] ?? ''),
              
              PdfStyles.sectionHeader('REASON FOR REFERRAL'),
              PdfStyles.textArea(data['reason_for_referral'], minHeight: 100),
              
              PdfStyles.sectionHeader('Challenges Presented'),
              PdfStyles.textArea(data['challenges_presented'], minHeight: 150),
              
              pw.Spacer(),
              
              // Referring party
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfStyles.signatureLine(data['referring_person'] ?? '', width: 200),
                  pw.SizedBox(height: 4),
                  PdfStyles.labelWithUnderline('Position', data['referring_position'] ?? ''),
                  PdfStyles.labelWithUnderline('Unit / Service', data['referring_unit'] ?? ''),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }

  // ============ INITIAL PSYCHOLOGICAL ASSESSMENT ============
  static List<pw.Page> _buildInitialAssessment(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    final interventions = (data['intervention_items'] as List<dynamic>?) ?? [];
    
    return [
      pw.MultiPage(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        header: (context) => _buildPsychHeader(context, 'INITIAL PSYCHOLOGICAL ASSESSMENT'),
        footer: (context) => PdfStyles.pageFooter(context),
        build: (context) => [
          PdfStyles.confidentialityNotice(),
          pw.SizedBox(height: 12),
          
          _buildIdentifyingData(data, residentName),
          
          PdfStyles.sectionHeader('II. REASON FOR REFERRAL'),
          PdfStyles.textArea(data['reason_for_referral'], minHeight: 60),
          
          PdfStyles.sectionHeader('III. ASSESSMENT TOOLS AND OTHER PROCEDURES'),
          PdfStyles.textArea(data['assessment_tools'], minHeight: 60),
          
          PdfStyles.sectionHeader('IV. RESULTS AND DISCUSSION'),
          PdfStyles.textArea(data['results_discussion'], minHeight: 120),
          
          _buildInterventionPlan(interventions),
          
          pw.SizedBox(height: 20),
          _buildPsychSignatures(data),
        ],
      ),
    ];
  }

  // ============ PSYCHOMETRICIAN'S REPORT ============
  static List<pw.Page> _buildPsychometricianReport(
    Map<String, dynamic> data,
    String residentName,
    Uint8List? logoBytes,
  ) {
    final interventions = (data['intervention_items'] as List<dynamic>?) ?? [];
    
    return [
      pw.MultiPage(
        pageFormat: PdfStyles.pageFormat,
        margin: PdfStyles.pageMargin,
        header: (context) => _buildPsychHeader(context, "PSYCHOMETRICIAN'S REPORT"),
        footer: (context) => PdfStyles.pageFooter(context),
        build: (context) => [
          PdfStyles.confidentialityNotice(),
          pw.SizedBox(height: 12),
          
          _buildIdentifyingDataExtended(data, residentName),
          
          PdfStyles.sectionHeader('II. REASON FOR REFERRAL'),
          PdfStyles.textArea(data['reason_for_referral'], minHeight: 60),
          
          PdfStyles.sectionHeader('BRIEF HISTORY'),
          PdfStyles.textArea(data['brief_history'], minHeight: 80),
          
          PdfStyles.sectionHeader('BEHAVIORAL OBSERVATION'),
          PdfStyles.textArea(data['behavioral_observation'], minHeight: 80),
          
          PdfStyles.sectionHeader('III. ASSESSMENT TOOLS AND OTHER PROCEDURES'),
          PdfStyles.textArea(data['assessment_tools'], minHeight: 60),
          
          PdfStyles.sectionHeader('MENTAL STATUS EXAMINATION'),
          PdfStyles.textArea(data['mental_status_exam'], minHeight: 80),
          
          PdfStyles.sectionHeader('IV. RESULTS AND DISCUSSION'),
          PdfStyles.textArea(data['results_discussion'], minHeight: 120),
          
          _buildInterventionPlan(interventions),
          
          pw.SizedBox(height: 20),
          _buildPsychSignatures(data),
        ],
      ),
    ];
  }

  // ============ HELPER METHODS ============

  static pw.Widget _buildPsychHeader(pw.Context context, String title) {
    if (context.pageNumber > 1) return pw.SizedBox();
    
    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    children: [
                      pw.Text('PSYCHOLOGICAL', style: PdfStyles.subHeaderStyle),
                      pw.Text('SERVICE', style: PdfStyles.subHeaderStyle),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Center(
                    child: pw.Text(title, style: PdfStyles.headerStyle, textAlign: pw.TextAlign.center),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '(Strictly Confidential / Not for Legal Use)',
                    style: PdfStyles.italicStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildIdentifyingData(Map<String, dynamic> data, String residentName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyles.sectionHeader('I. IDENTIFYING DATA'),
        pw.Row(children: [
          pw.Expanded(flex: 2, child: PdfStyles.labelWithUnderline('Name', data['name'] ?? residentName)),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Nickname', data['nickname'] ?? '')),
        ]),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Birth', PdfStyles.formatDate(data['date_of_birth']))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Age', data['age']?.toString() ?? '')),
          pw.SizedBox(width: 10),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Sex', data['sex'] ?? '')),
        ]),
        PdfStyles.labelWithUnderline('Address', data['address'] ?? ''),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Religious Affiliation', data['religious_affiliation'] ?? '')),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Educational Attainment', data['educational_attainment'] ?? '')),
        ]),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Admission', PdfStyles.formatDate(data['date_of_admission']))),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Assessment', PdfStyles.formatDate(data['date_of_assessment']))),
        ]),
        PdfStyles.labelWithUnderline('Date of Report', PdfStyles.formatDate(data['date_of_report'])),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildIdentifyingDataExtended(Map<String, dynamic> data, String residentName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyles.sectionHeader('I. IDENTIFYING DATA'),
        pw.Row(children: [
          pw.Expanded(flex: 2, child: PdfStyles.labelWithUnderline('Name', data['name'] ?? residentName)),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Nickname', data['nickname'] ?? '')),
        ]),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Birth', PdfStyles.formatDate(data['date_of_birth']))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Age', data['age']?.toString() ?? '')),
          pw.SizedBox(width: 10),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Sex', data['sex'] ?? '')),
        ]),
        PdfStyles.labelWithUnderline('Address', data['address'] ?? ''),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Religious Affiliation', data['religious_affiliation'] ?? '')),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Educational Attainment', data['educational_attainment'] ?? '')),
        ]),
        PdfStyles.labelWithUnderline('Category', data['category'] ?? ''),
        pw.Row(children: [
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Admission', PdfStyles.formatDate(data['date_of_admission']))),
          pw.SizedBox(width: 20),
          pw.Expanded(child: PdfStyles.labelWithUnderline('Date of Assessment', PdfStyles.formatDate(data['date_of_assessment']))),
        ]),
        PdfStyles.labelWithUnderline('Date of Report', PdfStyles.formatDate(data['date_of_report'])),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildInterventionPlan(List<dynamic> interventions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyles.sectionHeader('V. RECOMMENDATIONS / INTERVENTION PLAN'),
        pw.Table(
          border: pw.TableBorder.all(color: PdfStyles.borderColor, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfStyles.headerBgColor),
              children: [
                _cell('OBJECTIVES', isHeader: true),
                _cell('ACTIVITY', isHeader: true),
                _cell('RESPONSIBLE PERSON', isHeader: true),
                _cell('TIME FRAME', isHeader: true),
                _cell('OUTCOME', isHeader: true),
              ],
            ),
            ...interventions.map((item) {
              final i = item as Map<String, dynamic>;
              return pw.TableRow(
                children: [
                  _cellMinHeight(i['objectives'] ?? '', 30),
                  _cellMinHeight(i['activity'] ?? '', 30),
                  _cellMinHeight(i['responsible_person'] ?? '', 30),
                  _cellMinHeight(i['time_frame'] ?? '', 30),
                  _cellMinHeight(i['outcome'] ?? '', 30),
                ],
              );
            }),
            // Add empty rows if needed
            if (interventions.length < 5)
              ...List.generate(5 - interventions.length, (_) => pw.TableRow(
                children: [
                  _cellMinHeight('', 30),
                  _cellMinHeight('', 30),
                  _cellMinHeight('', 30),
                  _cellMinHeight('', 30),
                  _cellMinHeight('', 30),
                ],
              )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPsychSignatures(Map<String, dynamic> data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Prepared by:', style: PdfStyles.normalStyle),
            PdfStyles.signatureBlock(
              role: data['profession'] ?? 'Psychometrician',
              name: data['prepared_by'],
              licenseNo: data['license_no'],
              width: 200,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Noted by:', style: PdfStyles.normalStyle),
            PdfStyles.signatureBlock(
              role: data['noted_by_position'] ?? 'Center Head',
              name: data['noted_by'],
              width: 200,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: isHeader ? PdfStyles.labelStyle : PdfStyles.normalStyle,
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
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
