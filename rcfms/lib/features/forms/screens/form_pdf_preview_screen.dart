import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../templates/form_templates.dart';
import '../pdf/pdf_generator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Responsive screen for previewing and printing form PDFs
class FormPdfPreviewScreen extends StatefulWidget {
  final FormTemplate template;
  final Map<String, dynamic> formData;
  final String residentName;
  final String? caseNumber;

  const FormPdfPreviewScreen({
    super.key,
    required this.template,
    required this.formData,
    required this.residentName,
    this.caseNumber,
  });

  @override
  State<FormPdfPreviewScreen> createState() => _FormPdfPreviewScreenState();
}

class _FormPdfPreviewScreenState extends State<FormPdfPreviewScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await PdfGenerator.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.template.name,
              style: TextStyle(
                fontSize: screen.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
              ),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            actions: _buildActions(screen),
          ),
          body: _buildBody(screen),
        );
      },
    );
  }

  List<Widget> _buildActions(ScreenInfo screen) {
    if (screen.isMobile) {
      // Mobile: Use popup menu
      return [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'share':
                _sharePdf();
                break;
              case 'print':
                _printPdf();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share/Save'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'print',
              child: ListTile(
                leading: Icon(Icons.print),
                title: Text('Print'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ];
    }

    // Tablet/Desktop: Show action buttons
    return [
      TextButton.icon(
        onPressed: _sharePdf,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text('Share', style: TextStyle(color: Colors.white)),
      ),
      const SizedBox(width: 8),
      TextButton.icon(
        onPressed: _printPdf,
        icon: const Icon(Icons.print, color: Colors.white),
        label: const Text('Print', style: TextStyle(color: Colors.white)),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildBody(ScreenInfo screen) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
            Text(
              'Generating PDF...',
              style: TextStyle(
                fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screen.horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: screen.value(mobile: 48.0, tablet: 56.0, desktop: 64.0),
                color: AppColors.error,
              ),
              SizedBox(height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
              Text(
                'Error generating PDF',
                style: TextStyle(
                  fontSize: screen.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
                ),
              ),
              SizedBox(height: screen.value(mobile: 20.0, tablet: 22.0, desktop: 24.0)),
              ElevatedButton.icon(
                onPressed: _initialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview(
      build: (format) => _generatePdf(),
      canChangeOrientation: false,
      canChangePageFormat: false,
      allowPrinting: true,
      allowSharing: true,
      maxPageWidth: screen.value(mobile: 400.0, tablet: 600.0, desktop: 700.0),
      pdfFileName: _getFileName(),
      initialPageFormat: PdfPageFormat.letter,
      padding: EdgeInsets.all(screen.value(mobile: 8.0, tablet: 16.0, desktop: 24.0)),
      loadingWidget: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0)),
            Text(
              'Loading preview...',
              style: TextStyle(
                fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
              ),
            ),
          ],
        ),
      ),
      onError: (context, error) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: screen.value(mobile: 40.0, tablet: 44.0, desktop: 48.0),
                color: AppColors.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load PDF',
                style: TextStyle(
                  fontSize: screen.value(mobile: 15.0, tablet: 16.0, desktop: 17.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      actions: screen.isMobile
          ? [] // Hide default actions on mobile (we use menu)
          : [
              PdfPreviewAction(
                icon: const Icon(Icons.download),
                onPressed: _downloadPdf,
              ),
            ],
    );
  }

  Future<Uint8List> _generatePdf() async {
    final bytes = await PdfGenerator.generatePdf(
      template: widget.template,
      data: widget.formData,
      residentName: widget.residentName,
      caseNumber: widget.caseNumber,
    );
    return Uint8List.fromList(bytes);
  }

  String _getFileName() {
    final sanitizedName = widget.residentName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final sanitizedTemplate = widget.template.name.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final date = DateTime.now().toIso8601String().split('T')[0];
    return '${sanitizedTemplate}_${sanitizedName}_$date.pdf';
  }

  Future<void> _printPdf() async {
    try {
      await PdfGenerator.printPdf(
        template: widget.template,
        data: widget.formData,
        residentName: widget.residentName,
        caseNumber: widget.caseNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    try {
      await PdfGenerator.sharePdf(
        template: widget.template,
        data: widget.formData,
        residentName: widget.residentName,
        caseNumber: widget.caseNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, dynamic build, dynamic format) async {
    await _sharePdf();
  }
}

/// Responsive button widget to open PDF preview
class PdfPreviewButton extends StatelessWidget {
  final FormTemplate template;
  final Map<String, dynamic> formData;
  final String residentName;
  final String? caseNumber;
  final String? label;
  final IconData? icon;
  final bool expanded;

  const PdfPreviewButton({
    super.key,
    required this.template,
    required this.formData,
    required this.residentName,
    this.caseNumber,
    this.label,
    this.icon,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenInfo.of(context);
    
    final button = ElevatedButton.icon(
      onPressed: () => _openPreview(context),
      icon: Icon(
        icon ?? Icons.picture_as_pdf,
        size: screen.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
      ),
      label: Text(
        label ?? 'View PDF',
        style: TextStyle(
          fontSize: screen.value(mobile: 13.0, tablet: 14.0, desktop: 15.0),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: screen.value(mobile: 16.0, tablet: 20.0, desktop: 24.0),
          vertical: screen.value(mobile: 10.0, tablet: 12.0, desktop: 14.0),
        ),
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormPdfPreviewScreen(
          template: template,
          formData: formData,
          residentName: residentName,
          caseNumber: caseNumber,
        ),
      ),
    );
  }
}

/// Responsive quick print button
class QuickPrintButton extends StatelessWidget {
  final FormTemplate template;
  final Map<String, dynamic> formData;
  final String residentName;
  final String? caseNumber;
  final bool showLabel;

  const QuickPrintButton({
    super.key,
    required this.template,
    required this.formData,
    required this.residentName,
    this.caseNumber,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenInfo.of(context);
    
    if (showLabel || screen.isDesktop) {
      return TextButton.icon(
        onPressed: () => _print(context),
        icon: Icon(
          Icons.print,
          size: screen.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
        ),
        label: const Text('Print'),
      );
    }

    return IconButton(
      onPressed: () => _print(context),
      icon: Icon(
        Icons.print,
        size: screen.value(mobile: 22.0, tablet: 24.0, desktop: 26.0),
      ),
      tooltip: 'Print',
    );
  }

  Future<void> _print(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Flexible(child: Text('Preparing to print...')),
            ],
          ),
        ),
      );

      await PdfGenerator.printPdf(
        template: template,
        data: formData,
        residentName: residentName,
        caseNumber: caseNumber,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
