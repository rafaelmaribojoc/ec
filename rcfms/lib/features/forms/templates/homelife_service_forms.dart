import 'package:flutter/material.dart';
import 'form_field_builders.dart';

/// Home Life Service Form Templates
class HomeLifeServiceForms {
  HomeLifeServiceForms._();

  /// Get form fields for home life service templates
  /// [readOnly] - If true, all fields will be disabled (for approval view)
  static List<Widget> getFormFields(
    String templateType,
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged, {
    bool readOnly = false,
  }) {
    switch (templateType) {
      case 'inventory_admission':
        return _inventoryUponAdmission(data, onChanged);
      case 'inventory_discharge':
        return _inventoryUponDischarge(data, onChanged);
      case 'inventory_monthly':
        return _inventoryMonthly(data, onChanged);
      case 'progress_notes':
        return _progressNotes(data, onChanged);
      case 'incident_report':
        return _incidentReport(data, onChanged);
      case 'out_on_pass':
        return _outOnPass(data, onChanged);
      default:
        return [const Text('Unknown form type')];
    }
  }

  // INVENTORY UPON ADMISSION
  static List<Widget> _inventoryUponAdmission(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('INVENTORY OF BELONGINGS'),
      FormFieldBuilders.infoText(
          'Record all belongings of the client upon admission'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['inventory_date'],
        onChanged: (v) => onChanged('inventory_date', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Belongings Inventory'),
      _inventoryTable(data, onChanged, 'admission'),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Referring Party',
              value: data['referring_party'] ?? '',
              onChanged: (v) => onChanged('referring_party', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Inspected By (HP on duty)',
              value: data['inspected_by'] ?? '',
              onChanged: (v) => onChanged('inspected_by', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Attested By (Supervising HP)',
              value: data['attested_by'] ?? '',
              onChanged: (v) => onChanged('attested_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Noted By (Center Head)',
              value: data['noted_by'] ?? '',
              onChanged: (v) => onChanged('noted_by', v),
            ),
          ),
        ],
      ),
    ];
  }

  // INVENTORY UPON DISCHARGE
  static List<Widget> _inventoryUponDischarge(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('INVENTORY OF BELONGINGS'),
      FormFieldBuilders.infoText(
          'Record all belongings being released to the client upon discharge'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['inventory_date'],
        onChanged: (v) => onChanged('inventory_date', v?.toIso8601String()),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Belongings Inventory'),
      _inventoryTable(data, onChanged, 'discharge'),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Receiving Party',
              value: data['receiving_party'] ?? '',
              onChanged: (v) => onChanged('receiving_party', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Inspected By (HP on duty)',
              value: data['inspected_by'] ?? '',
              onChanged: (v) => onChanged('inspected_by', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Attested By (Supervising HP)',
              value: data['attested_by'] ?? '',
              onChanged: (v) => onChanged('attested_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Noted By (Center Head)',
              value: data['noted_by'] ?? '',
              onChanged: (v) => onChanged('noted_by', v),
            ),
          ),
        ],
      ),
    ];
  }

  // MONTHLY INVENTORY
  static List<Widget> _inventoryMonthly(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('INVENTORY OF BELONGINGS'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Month',
              value: data['month'] ?? 'January',
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
              onChanged: (v) => onChanged('month', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Year',
              value: data['year']?.toString() ?? DateTime.now().year.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged('year', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('A. Clothing'),
      _inventoryCategoryTable(data, onChanged, 'clothing'),
      FormFieldBuilders.sectionHeader('B. Toiletries'),
      _inventoryCategoryTable(data, onChanged, 'toiletries'),
      FormFieldBuilders.sectionHeader('C. Linen'),
      _inventoryCategoryTable(data, onChanged, 'linen'),
      FormFieldBuilders.sectionHeader('D. Others'),
      _inventoryCategoryTable(data, onChanged, 'others'),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Prepared By (HP II)',
              value: data['prepared_by'] ?? '',
              onChanged: (v) => onChanged('prepared_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Submitted By (Supervising HP III)',
              value: data['submitted_by'] ?? '',
              onChanged: (v) => onChanged('submitted_by', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Noted By (Center Head)',
        value: data['noted_by'] ?? '',
        onChanged: (v) => onChanged('noted_by', v),
      ),
    ];
  }

  // Helper: Inventory table
  static Widget _inventoryTable(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
    String prefix,
  ) {
    final items = (data['${prefix}_items'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        FormFieldBuilders.tableHeader(
          ['Particulars', 'Qty', 'Unit', 'Description', 'Unit Cost', 'Balance'],
          flexValues: [3, 1, 1, 3, 2, 2],
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          return FormFieldBuilders.tableRow(
            cells: [
              TextFormField(
                initialValue: item['particulars'] ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['particulars'] = v;
                  onChanged('${prefix}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['qty']?.toString() ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['qty'] = int.tryParse(v) ?? 0;
                  onChanged('${prefix}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['unit'] ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['unit'] = v;
                  onChanged('${prefix}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['description'] ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['description'] = v;
                  onChanged('${prefix}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['unit_cost']?.toString() ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['unit_cost'] = double.tryParse(v) ?? 0;
                  onChanged('${prefix}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['balance']?.toString() ?? '',
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['balance'] = double.tryParse(v) ?? 0;
                  onChanged('${prefix}_items', newItems);
                },
              ),
            ],
            flexValues: [3, 1, 1, 3, 2, 2],
            onDelete: () {
              final newItems = List<Map<String, dynamic>>.from(items);
              newItems.removeAt(index);
              onChanged('${prefix}_items', newItems);
            },
          );
        }),
        FormFieldBuilders.addRowButton(() {
          final newItems = List<Map<String, dynamic>>.from(items);
          newItems.add({
            'particulars': '',
            'qty': 0,
            'unit': 'pc',
            'description': '',
            'unit_cost': 0.0,
            'balance': 0.0,
          });
          onChanged('${prefix}_items', newItems);
        }),
      ],
    );
  }

  // Helper: Inventory category table (for monthly)
  static Widget _inventoryCategoryTable(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
    String category,
  ) {
    final items = (data['${category}_items'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        FormFieldBuilders.tableHeader(
          ['Particulars', 'Qty', 'Unit', 'Description', 'Unit Cost', 'Balance'],
          flexValues: [3, 1, 1, 3, 2, 2],
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          return FormFieldBuilders.tableRow(
            cells: [
              TextFormField(
                initialValue: item['particulars'] ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['particulars'] = v;
                  onChanged('${category}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['qty']?.toString() ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['qty'] = int.tryParse(v) ?? 0;
                  onChanged('${category}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['unit'] ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['unit'] = v;
                  onChanged('${category}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['description'] ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['description'] = v;
                  onChanged('${category}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['unit_cost']?.toString() ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['unit_cost'] = double.tryParse(v) ?? 0;
                  onChanged('${category}_items', newItems);
                },
              ),
              TextFormField(
                initialValue: item['balance']?.toString() ?? '',
                decoration: const InputDecoration(
                    isDense: true, border: InputBorder.none),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (v) {
                  final newItems = List<Map<String, dynamic>>.from(items);
                  newItems[index]['balance'] = double.tryParse(v) ?? 0;
                  onChanged('${category}_items', newItems);
                },
              ),
            ],
            flexValues: [3, 1, 1, 3, 2, 2],
            onDelete: () {
              final newItems = List<Map<String, dynamic>>.from(items);
              newItems.removeAt(index);
              onChanged('${category}_items', newItems);
            },
          );
        }),
        FormFieldBuilders.addRowButton(() {
          final newItems = List<Map<String, dynamic>>.from(items);
          newItems.add({
            'particulars': '',
            'qty': 0,
            'unit': 'pc',
            'description': '',
            'unit_cost': 0.0,
            'balance': 0.0,
          });
          onChanged('${category}_items', newItems);
        }),
      ],
    );
  }

  // PROGRESS NOTES
  static List<Widget> _progressNotes(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final entries = (data['progress_entries'] as List<dynamic>?) ?? [];

    return [
      FormFieldBuilders.sectionHeader('PROGRESS NOTES'),
      FormFieldBuilders.textField(
        label: 'Name of Client',
        value: data['client_name'] ?? '',
        onChanged: (v) => onChanged('client_name', v),
        required: true,
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.tableHeader(
        ['Date', 'Activities Undertaken', 'Supervisory Remarks'],
        flexValues: [1, 3, 2],
      ),
      ...entries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        return FormFieldBuilders.tableRow(
          cells: [
            Builder(
              builder: (context) => InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: item['date'] != null
                        ? DateTime.tryParse(item['date']) ?? DateTime.now()
                        : DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final newEntries = List<Map<String, dynamic>>.from(entries);
                    newEntries[index]['date'] = date.toIso8601String();
                    onChanged('progress_entries', newEntries);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item['date'] != null ? _formatDate(item['date']) : 'Select',
                    style: TextStyle(
                      color: item['date'] != null ? null : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            TextFormField(
              initialValue: item['activities'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Enter activities...',
              ),
              maxLines: 3,
              onChanged: (v) {
                final newEntries = List<Map<String, dynamic>>.from(entries);
                newEntries[index]['activities'] = v;
                onChanged('progress_entries', newEntries);
              },
            ),
            TextFormField(
              initialValue: item['remarks'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Enter remarks...',
              ),
              maxLines: 3,
              onChanged: (v) {
                final newEntries = List<Map<String, dynamic>>.from(entries);
                newEntries[index]['remarks'] = v;
                onChanged('progress_entries', newEntries);
              },
            ),
          ],
          flexValues: [1, 3, 2],
          onDelete: () {
            final newEntries = List<Map<String, dynamic>>.from(entries);
            newEntries.removeAt(index);
            onChanged('progress_entries', newEntries);
          },
        );
      }),
      FormFieldBuilders.addRowButton(() {
        final newEntries = List<Map<String, dynamic>>.from(entries);
        newEntries.add({
          'date': DateTime.now().toIso8601String(),
          'activities': '',
          'remarks': '',
        });
        onChanged('progress_entries', newEntries);
      }),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Prepared By (Houseparent I)',
              value: data['prepared_by'] ?? '',
              onChanged: (v) => onChanged('prepared_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Noted By (Center Head)',
              value: data['noted_by'] ?? '',
              onChanged: (v) => onChanged('noted_by', v),
            ),
          ),
        ],
      ),
    ];
  }

  // INCIDENT REPORT
  static List<Widget> _incidentReport(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    final actions = (data['action_items'] as List<dynamic>?) ?? [];

    return [
      FormFieldBuilders.sectionHeader('INCIDENT REPORT'),
      FormFieldBuilders.textArea(
        label: 'WHAT (Anong Nangyari)',
        value: data['what_happened'] ?? '',
        onChanged: (v) => onChanged('what_happened', v),
        required: true,
      ),
      FormFieldBuilders.textArea(
        label: 'WHO (Sino ang Kasali)',
        value: data['who_involved'] ?? '',
        onChanged: (v) => onChanged('who_involved', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.datePicker(
              label: 'WHEN - Date',
              value: data['when_date'],
              onChanged: (v) => onChanged('when_date', v?.toIso8601String()),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.timePicker(
              label: 'WHEN - Time',
              value: data['when_time'],
              onChanged: (v) => onChanged('when_time', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'WHERE (Saan)',
        value: data['where'] ?? '',
        onChanged: (v) => onChanged('where', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Action Taken & Recommendations'),
      FormFieldBuilders.tableHeader(
        ['Action Taken', 'Recommendation', 'Responsible Person'],
        flexValues: [2, 2, 2],
      ),
      ...actions.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        return FormFieldBuilders.tableRow(
          cells: [
            TextFormField(
              initialValue: item['action'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Action taken...',
              ),
              maxLines: 2,
              onChanged: (v) {
                final newActions = List<Map<String, dynamic>>.from(actions);
                newActions[index]['action'] = v;
                onChanged('action_items', newActions);
              },
            ),
            TextFormField(
              initialValue: item['recommendation'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Recommendation...',
              ),
              maxLines: 2,
              onChanged: (v) {
                final newActions = List<Map<String, dynamic>>.from(actions);
                newActions[index]['recommendation'] = v;
                onChanged('action_items', newActions);
              },
            ),
            TextFormField(
              initialValue: item['responsible_person'] ?? '',
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Person...',
              ),
              onChanged: (v) {
                final newActions = List<Map<String, dynamic>>.from(actions);
                newActions[index]['responsible_person'] = v;
                onChanged('action_items', newActions);
              },
            ),
          ],
          flexValues: [2, 2, 2],
          onDelete: () {
            final newActions = List<Map<String, dynamic>>.from(actions);
            newActions.removeAt(index);
            onChanged('action_items', newActions);
          },
        );
      }),
      FormFieldBuilders.addRowButton(() {
        final newActions = List<Map<String, dynamic>>.from(actions);
        newActions.add({
          'action': '',
          'recommendation': '',
          'responsible_person': '',
        });
        onChanged('action_items', newActions);
      }),
      const SizedBox(height: 24),
      FormFieldBuilders.sectionHeader('Signatures'),
      FormFieldBuilders.textField(
        label: 'Prepared By',
        value: data['prepared_by'] ?? '',
        onChanged: (v) => onChanged('prepared_by', v),
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Attested By (Supervising HP)',
              value: data['attested_by'] ?? '',
              onChanged: (v) => onChanged('attested_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Noted By (Center Head)',
              value: data['noted_by'] ?? '',
              onChanged: (v) => onChanged('noted_by', v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Received by:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Social Services',
              value: data['received_social'] ?? '',
              onChanged: (v) => onChanged('received_social', v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Psych. Services',
              value: data['received_psych'] ?? '',
              onChanged: (v) => onChanged('received_psych', v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Medical Services',
              value: data['received_medical'] ?? '',
              onChanged: (v) => onChanged('received_medical', v),
            ),
          ),
        ],
      ),
    ];
  }

  // OUT ON PASS
  static List<Widget> _outOnPass(
    Map<String, dynamic> data,
    void Function(String, dynamic) onChanged,
  ) {
    return [
      FormFieldBuilders.sectionHeader('OUT ON PASS'),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Republic of the Philippines',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Department of Social Welfare and Development'),
            const Text('Field Office XI'),
            const Text('HOME FOR THE AGED'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.datePicker(
        label: 'Date',
        value: data['pass_date'],
        onChanged: (v) => onChanged('pass_date', v?.toIso8601String()),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Client Name',
              value: data['client_name'] ?? '',
              onChanged: (v) => onChanged('client_name', v),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Age',
              value: data['client_age']?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged('client_age', v),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.timePicker(
              label: 'Time Out',
              value: data['time_out'],
              onChanged: (v) => onChanged('time_out', v),
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.timePicker(
              label: 'Time In',
              value: data['time_in'],
              onChanged: (v) => onChanged('time_in', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textArea(
        label: 'Purpose',
        value: data['purpose'] ?? '',
        onChanged: (v) => onChanged('purpose', v),
        required: true,
      ),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Escorted By',
              value: data['escorted_by'] ?? '',
              onChanged: (v) => onChanged('escorted_by', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.dropdown(
              label: 'Position',
              value: data['escort_position'] ?? 'nurse',
              items: const ['Nurse', 'Houseparent', 'Social Worker', 'Other'],
              onChanged: (v) => onChanged('escort_position', v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Nature of Out-slip'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'Personal',
              value: data['nature_personal'] ?? false,
              onChanged: (v) => onChanged('nature_personal', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'Medical',
              value: data['nature_medical'] ?? false,
              onChanged: (v) => onChanged('nature_medical', v),
            ),
          ),
          Expanded(
            child: FormFieldBuilders.checkbox(
              label: 'Official',
              value: data['nature_official'] ?? false,
              onChanged: (v) => onChanged('nature_official', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textArea(
        label: 'Notice/Reminders',
        value: data['notices'] ??
            'The Home for the Aged will not be held liable for any untoward incident affecting the client outside the center.',
        onChanged: (v) => onChanged('notices', v),
      ),
      const SizedBox(height: 16),
      FormFieldBuilders.sectionHeader('Acknowledgment & Approval'),
      Row(
        children: [
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Supervising Houseparent III',
              value: data['supervising_hp'] ?? '',
              onChanged: (v) => onChanged('supervising_hp', v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FormFieldBuilders.textField(
              label: 'Center Doctor',
              value: data['center_doctor'] ?? '',
              onChanged: (v) => onChanged('center_doctor', v),
            ),
          ),
        ],
      ),
      FormFieldBuilders.textField(
        label: 'Social Worker',
        value: data['social_worker'] ?? '',
        onChanged: (v) => onChanged('social_worker', v),
      ),
      FormFieldBuilders.signatureField(
        label: 'Client Signature',
        signatureUrl: data['client_signature_url'],
        onCapture: () {
          // TODO: Implement signature capture
        },
      ),
      FormFieldBuilders.textField(
        label: 'Approved By (Center Head)',
        value: data['approved_by'] ?? '',
        onChanged: (v) => onChanged('approved_by', v),
      ),
    ];
  }

  // Helper to format date
  static String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.month}/${date.day}/${date.year}';
  }
}
