import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/ward_model.dart';
import '../../../data/repositories/resident_repository.dart';

class AddResidentScreen extends StatefulWidget {
  const AddResidentScreen({super.key});

  @override
  State<AddResidentScreen> createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends State<AddResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _bedNumberController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _admissionDate;
  String _gender = 'male';
  WardModel? _selectedWard;
  List<WardModel> _wards = [];
  Uint8List? _photoBytes;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadWards();
    _admissionDate = DateTime.now();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _roomNumberController.dispose();
    _bedNumberController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    _allergiesController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWards() async {
    try {
      final repository = context.read<ResidentRepository>();
      final wards = await repository.getWards();
      setState(() {
        _wards = wards;
        if (wards.isNotEmpty) {
          _selectedWard = wards.first;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _photoBytes = bytes;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final now = DateTime.now();
    final initialDate = isBirthDate
        ? (_dateOfBirth ?? DateTime(now.year - 70))
        : (_admissionDate ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (date != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = date;
        } else {
          _admissionDate = date;
        }
      });
    }
  }

  Future<void> _saveResident() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }
    if (_selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ward')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = context.read<ResidentRepository>();
      await repository.addResident(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        wardId: _selectedWard!.id,
        roomNumber: _roomNumberController.text.trim().isEmpty
            ? null
            : _roomNumberController.text.trim(),
        bedNumber: _bedNumberController.text.trim().isEmpty
            ? null
            : _bedNumberController.text.trim(),
        admissionDate: _admissionDate ?? DateTime.now(),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        emergencyContactRelation: _emergencyRelationController.text.trim().isEmpty
            ? null
            : _emergencyRelationController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        primaryDiagnosis: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        medicalNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photoBytes: _photoBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resident added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add resident: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Resident'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep++;
              });
            } else {
              _saveResident();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading && _currentStep == 2
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentStep == 2 ? 'Save Resident' : 'Continue'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Basic Info
            Step(
              title: const Text('Basic Information'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildBasicInfoStep(),
            ),
            // Step 2: Location
            Step(
              title: const Text('Ward & Location'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildLocationStep(),
            ),
            // Step 3: Additional Info
            Step(
              title: const Text('Additional Details'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildAdditionalStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        // Photo picker
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            backgroundImage: _photoBytes != null
                ? MemoryImage(_photoBytes!)
                : null,
            child: _photoBytes == null
                ? const Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _pickImage,
          child: const Text('Add Photo'),
        ),
        const SizedBox(height: 16),
        // Name fields
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name *',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'First name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name *',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Last name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _middleNameController,
          decoration: const InputDecoration(
            labelText: 'Middle Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        // Date of birth
        InkWell(
          onTap: () => _selectDate(context, true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of Birth *',
              prefixIcon: Icon(Icons.cake),
            ),
            child: Text(
              _dateOfBirth != null
                  ? DateFormat('MMMM d, yyyy').format(_dateOfBirth!)
                  : 'Select date',
              style: TextStyle(
                color: _dateOfBirth != null
                    ? AppColors.textPrimaryLight
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Gender
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(
            labelText: 'Gender *',
            prefixIcon: Icon(Icons.wc),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _gender = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        // Ward selection
        DropdownButtonFormField<WardModel>(
          value: _selectedWard,
          decoration: const InputDecoration(
            labelText: 'Ward *',
            prefixIcon: Icon(Icons.room),
          ),
          items: _wards
              .map((ward) => DropdownMenuItem(
                    value: ward,
                    child: Text(ward.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedWard = value;
            });
          },
          validator: (value) => value == null ? 'Please select a ward' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _bedNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bed Number',
                  prefixIcon: Icon(Icons.bed),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Admission date
        InkWell(
          onTap: () => _selectDate(context, false),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Admission Date *',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _admissionDate != null
                  ? DateFormat('MMMM d, yyyy').format(_admissionDate!)
                  : 'Select date',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contact',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emergencyNameController,
          decoration: const InputDecoration(
            labelText: 'Contact Name',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emergencyPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contact Phone',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emergencyRelationController,
          decoration: const InputDecoration(
            labelText: 'Relationship',
            prefixIcon: Icon(Icons.family_restroom),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Medical Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _diagnosisController,
          decoration: const InputDecoration(
            labelText: 'Primary Diagnosis',
            prefixIcon: Icon(Icons.medical_services),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _allergiesController,
          decoration: const InputDecoration(
            labelText: 'Allergies',
            prefixIcon: Icon(Icons.warning),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Additional Notes',
            prefixIcon: Icon(Icons.notes),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
