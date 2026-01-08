import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../templates/form_templates.dart';
import 'pdf_styles.dart';
import 'social_service_pdf.dart';
import 'homelife_service_pdf.dart';
import 'psychological_service_pdf.dart';

/// Main PDF Generator service
class PdfGenerator {
  PdfGenerator._();

  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _italicFont;
  static Uint8List? _logoBytes;

  /// Initialize fonts and assets
  static Future<void> initialize() async {
    try {
      // Load fonts - using default PDF fonts for reliability
      _regularFont = pw.Font.times();
      _boldFont = pw.Font.timesBold();
      _italicFont = pw.Font.timesItalic();

      // Try to load logo if available
      try {
        _logoBytes = (await rootBundle.load('assets/images/dswd_logo.png'))
            .buffer
            .asUint8List();
      } catch (e) {
        // Logo not available, will use text header
        _logoBytes = null;
      }
    } catch (e) {
      // Use default fonts
      _regularFont = null;
      _boldFont = null;
      _italicFont = null;
    }
  }

  /// Generate PDF for a form submission
  static Future<Uint8List> generatePdf({
    required FormTemplate template,
    required Map<String, dynamic> data,
    required String residentName,
    String? caseNumber,
  }) async {
    await initialize();

    final pdf = pw.Document(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: _regularFont,
          fontSize: 11,
        ),
      ),
    );

    // Get the appropriate PDF builder based on service unit
    final pages = _buildFormPages(template, data, residentName, caseNumber);

    for (final page in pages) {
      pdf.addPage(page);
    }

    return pdf.save();
  }

  /// Build form pages based on template
  static List<pw.Page> _buildFormPages(
    FormTemplate template,
    Map<String, dynamic> data,
    String residentName,
    String? caseNumber,
  ) {
    switch (template.serviceUnit) {
      case ServiceUnit.socialService:
        return SocialServicePdf.buildPages(
          template: template,
          data: data,
          residentName: residentName,
          caseNumber: caseNumber,
          logoBytes: _logoBytes,
        );
      case ServiceUnit.homeLifeService:
        return HomeLifeServicePdf.buildPages(
          template: template,
          data: data,
          residentName: residentName,
          caseNumber: caseNumber,
          logoBytes: _logoBytes,
        );
      case ServiceUnit.psychologicalService:
        return PsychologicalServicePdf.buildPages(
          template: template,
          data: data,
          residentName: residentName,
          caseNumber: caseNumber,
          logoBytes: _logoBytes,
        );
      case ServiceUnit.medicalService:
        // TODO: Implement medical service PDF
        return [_buildPlaceholderPage('Medical Service forms coming soon')];
    }
  }

  static pw.Page _buildPlaceholderPage(String message) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (context) => pw.Center(
        child: pw.Text(message),
      ),
    );
  }

  /// Print the PDF directly
  static Future<void> printPdf({
    required FormTemplate template,
    required Map<String, dynamic> data,
    required String residentName,
    String? caseNumber,
  }) async {
    final pdfBytes = await generatePdf(
      template: template,
      data: data,
      residentName: residentName,
      caseNumber: caseNumber,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: '${template.name} - $residentName',
    );
  }

  /// Share/Save the PDF
  static Future<void> sharePdf({
    required FormTemplate template,
    required Map<String, dynamic> data,
    required String residentName,
    String? caseNumber,
  }) async {
    final pdfBytes = await generatePdf(
      template: template,
      data: data,
      residentName: residentName,
      caseNumber: caseNumber,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${template.name.replaceAll(' ', '_')}_${residentName.replaceAll(' ', '_')}.pdf',
    );
  }
}
