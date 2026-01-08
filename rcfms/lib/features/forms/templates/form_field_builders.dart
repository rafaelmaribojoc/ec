import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Helper class for building responsive form fields
class FormFieldBuilders {
  FormFieldBuilders._();

  /// Section header
  static Widget sectionHeader(String title) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            top: screen.value(mobile: 20.0, tablet: 24.0, desktop: 28.0),
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screen.value(mobile: 16.0, tablet: 17.0, desktop: 18.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: screen.value(mobile: 50.0, tablet: 55.0, desktop: 60.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Standard text field - responsive
  static Widget textField({
    required String label,
    required String value,
    required void Function(String) onChanged,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    bool enabled = true,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                vertical: screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
              ),
              labelStyle: TextStyle(
                fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
              ),
            ),
            style: TextStyle(
              fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            onChanged: onChanged,
            validator: required
                ? (v) => (v == null || v.isEmpty) ? 'This field is required' : null
                : null,
          ),
        );
      },
    );
  }

  /// Text area (multiline) - responsive
  static Widget textArea({
    required String label,
    required String value,
    required void Function(String) onChanged,
    bool required = false,
    int maxLines = 4,
    String? hint,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              hintText: hint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                vertical: screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
              ),
            ),
            style: TextStyle(
              fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
            ),
            maxLines: screen.isMobile ? (maxLines - 1).clamp(2, 6) : maxLines,
            onChanged: onChanged,
            validator: required
                ? (v) => (v == null || v.isEmpty) ? 'This field is required' : null
                : null,
          ),
        );
      },
    );
  }

  /// Dropdown selector - responsive
  static Widget dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: DropdownButtonFormField<String>(
            value: items.map((e) => e.toLowerCase()).contains(value.toLowerCase())
                ? items.firstWhere((e) => e.toLowerCase() == value.toLowerCase())
                : items.first,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                vertical: screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
              ),
            ),
            style: TextStyle(
              fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
              color: AppColors.textPrimary,
            ),
            isExpanded: true,
            items: items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  /// Date picker - responsive
  static Widget datePicker({
    required String label,
    required dynamic value,
    required void Function(DateTime?) onChanged,
    bool required = false,
  }) {
    DateTime? dateValue;
    if (value is DateTime) {
      dateValue = value;
    } else if (value is String && value.isNotEmpty) {
      dateValue = DateTime.tryParse(value);
    }

    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateValue ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                onChanged(date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: required ? '$label *' : label,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  size: screen.value(mobile: 20.0, tablet: 22.0, desktop: 24.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                  vertical: screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
                ),
              ),
              child: Text(
                dateValue != null
                    ? '${dateValue.month}/${dateValue.day}/${dateValue.year}'
                    : 'Select date',
                style: TextStyle(
                  color: dateValue != null ? AppColors.textPrimary : AppColors.textHint,
                  fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Time picker - responsive
  static Widget timePicker({
    required String label,
    required dynamic value,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    TimeOfDay? timeValue;
    if (value is String && value.isNotEmpty) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        timeValue = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: timeValue ?? TimeOfDay.now(),
              );
              if (time != null) {
                onChanged('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: required ? '$label *' : label,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.access_time,
                  size: screen.value(mobile: 20.0, tablet: 22.0, desktop: 24.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                  vertical: screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
                ),
              ),
              child: Text(
                timeValue != null ? timeValue.format(context) : 'Select time',
                style: TextStyle(
                  color: timeValue != null ? AppColors.textPrimary : AppColors.textHint,
                  fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Responsive row - becomes column on mobile
  static Widget responsiveRow({
    required List<Widget> children,
    double spacing = 16,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        
        if (screen.isMobile) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.asMap().entries.map((entry) {
            final isLast = entry.key == children.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : spacing),
                child: entry.value,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Checkbox with remarks - responsive
  static Widget checkboxWithRemarks({
    required String label,
    required bool checked,
    required String remarks,
    required void Function(bool?) onCheckedChanged,
    required void Function(String) onRemarksChanged,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        
        if (screen.isMobile) {
          // Stack vertically on mobile
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: checked,
                        onChanged: onCheckedChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 8),
                  child: TextFormField(
                    initialValue: remarks,
                    decoration: const InputDecoration(
                      hintText: 'Remarks',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: onRemarksChanged,
                  ),
                ),
              ],
            ),
          );
        }

        // Side by side on larger screens
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: checked,
                  onChanged: onCheckedChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: remarks,
                  decoration: const InputDecoration(
                    hintText: 'Remarks',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: onRemarksChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Simple checkbox
  static Widget checkbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }

  /// Radio group - responsive
  static Widget radioGroup({
    required String label,
    required String groupValue,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: options.map(
                  (option) => SizedBox(
                    width: screen.isMobile ? double.infinity : null,
                    child: RadioListTile<String>(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                        ),
                      ),
                      value: option.toLowerCase(),
                      groupValue: groupValue.toLowerCase(),
                      onChanged: onChanged,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Signature field placeholder - responsive
  static Widget signatureField({
    required String label,
    required String? signatureUrl,
    required VoidCallback onCapture,
    bool required = false,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                required ? '$label *' : label,
                style: TextStyle(
                  fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: screen.value(mobile: 80.0, tablet: 90.0, desktop: 100.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade50,
                ),
                child: signatureUrl != null
                    ? Stack(
                        children: [
                          Center(
                            child: Image.network(
                              signatureUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: onCapture,
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: onCapture,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.draw,
                                color: Colors.grey,
                                size: screen.value(mobile: 24.0, tablet: 28.0, desktop: 32.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to sign',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screen.value(mobile: 12.0, tablet: 13.0, desktop: 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Responsive table header
  static Widget tableHeader(List<String> columns, {List<int>? flexValues}) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        
        // On mobile, show as card header
        if (screen.isMobile && columns.length > 3) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              'Form Entries',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screen.value(mobile: 8.0, tablet: 10.0, desktop: 12.0),
            horizontal: screen.value(mobile: 6.0, tablet: 7.0, desktop: 8.0),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: columns.asMap().entries.map((entry) {
              final flex = flexValues != null && entry.key < flexValues.length
                  ? flexValues[entry.key]
                  : 1;
              return Expanded(
                flex: flex,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.value(mobile: 11.0, tablet: 12.0, desktop: 13.0),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Responsive table row
  static Widget tableRow({
    required List<Widget> cells,
    List<int>? flexValues,
    VoidCallback? onDelete,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        
        // On mobile with many columns, show as card
        if (screen.isMobile && cells.length > 3) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cells.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: entry.value,
                    );
                  }),
                  if (onDelete != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screen.value(mobile: 6.0, tablet: 7.0, desktop: 8.0),
            horizontal: screen.value(mobile: 6.0, tablet: 7.0, desktop: 8.0),
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              right: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...cells.asMap().entries.map((entry) {
                final flex = flexValues != null && entry.key < flexValues.length
                    ? flexValues[entry.key]
                    : 1;
                return Expanded(
                  flex: flex,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: entry.value,
                  ),
                );
              }),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Add row button
  static Widget addRowButton(VoidCallback onPressed) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            top: screen.value(mobile: 8.0, tablet: 10.0, desktop: 12.0),
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: screen.isMobile
              ? SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entry'),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                ),
        );
      },
    );
  }

  /// Divider
  static Widget divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(),
    );
  }

  /// Info text - responsive
  static Widget infoText(String text) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(
              screen.value(mobile: 10.0, tablet: 11.0, desktop: 12.0),
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: screen.value(mobile: 18.0, tablet: 19.0, desktop: 20.0),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: screen.value(mobile: 12.0, tablet: 12.5, desktop: 13.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Image picker - responsive
  static Widget imagePicker({
    required String label,
    required String? imageUrl,
    required VoidCallback onPick,
  }) {
    return Builder(
      builder: (context) {
        final screen = ScreenInfo.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: screen.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screen.value(mobile: 14.0, tablet: 15.0, desktop: 16.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: screen.value(mobile: 120.0, tablet: 135.0, desktop: 150.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade50,
                ),
                child: imageUrl != null
                    ? Stack(
                        children: [
                          Center(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: onPick,
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: onPick,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                color: Colors.grey,
                                size: screen.value(mobile: 28.0, tablet: 30.0, desktop: 32.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screen.value(mobile: 12.0, tablet: 13.0, desktop: 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
