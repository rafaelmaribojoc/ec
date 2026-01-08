import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/form_submission_model.dart';
import '../models/timeline_entry_model.dart';
import '../../core/constants/app_constants.dart';

/// Repository for form operations
class FormRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get forms for current user
  Future<List<FormSubmissionModel>> getMyForms({
    String? status,
    String? unit,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Build filter query first, then order and paginate
      var query = _supabase
          .from('form_submissions')
          .select('''
            *,
            resident:residents(first_name, last_name),
            submitter:profiles!form_submissions_submitted_by_fkey(full_name, signature_url),
            reviewer:profiles!form_submissions_reviewed_by_fkey(full_name, signature_url)
          ''')
          .eq('submitted_by', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (unit != null) {
        query = query.eq('unit', unit);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      
      return response.map((json) => FormSubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch forms: $e');
    }
  }

  /// Get forms pending approval for unit head
  Future<List<FormSubmissionModel>> getPendingApprovals({
    required String unit,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _supabase
          .from('form_submissions')
          .select('''
            *,
            resident:residents(first_name, last_name),
            submitter:profiles!form_submissions_submitted_by_fkey(full_name, signature_url)
          ''')
          .eq('unit', unit)
          .eq('status', AppConstants.statusPendingReview)
          .order('submitted_at', ascending: true)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return response.map((json) => FormSubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }

  /// Get forms for a specific resident
  Future<List<FormSubmissionModel>> getResidentForms({
    required String residentId,
    String? unit,
    String? status,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      var query = _supabase
          .from('form_submissions')
          .select('''
            *,
            submitter:profiles!form_submissions_submitted_by_fkey(full_name, signature_url),
            reviewer:profiles!form_submissions_reviewed_by_fkey(full_name, signature_url)
          ''')
          .eq('resident_id', residentId);

      if (unit != null) {
        query = query.eq('unit', unit);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      
      return response.map((json) => FormSubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch resident forms: $e');
    }
  }

  /// Get single form by ID
  Future<FormSubmissionModel> getFormById(String id) async {
    try {
      final response = await _supabase
          .from('form_submissions')
          .select('''
            *,
            resident:residents(first_name, last_name),
            submitter:profiles!form_submissions_submitted_by_fkey(full_name, signature_url),
            reviewer:profiles!form_submissions_reviewed_by_fkey(full_name, signature_url)
          ''')
          .eq('id', id)
          .single();

      return FormSubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch form: $e');
    }
  }

  /// Create draft form
  Future<FormSubmissionModel> createDraft({
    required String residentId,
    required String templateId,
    required String templateType,
    required String unit,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('form_submissions')
          .insert({
            'resident_id': residentId,
            'template_id': templateId,
            'template_type': templateType,
            'unit': unit,
            'form_data': formData,
            'status': AppConstants.statusDraft,
            'submitted_by': userId,
          })
          .select()
          .single();

      return FormSubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create draft: $e');
    }
  }

  /// Update draft form
  Future<FormSubmissionModel> updateDraft({
    required String id,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final response = await _supabase
          .from('form_submissions')
          .update({
            'form_data': formData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return FormSubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update draft: $e');
    }
  }

  /// Submit form for review (with signature)
  Future<FormSubmissionModel> submitForm({
    required String id,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('form_submissions')
          .update({
            'form_data': formData,
            'status': AppConstants.statusPendingReview,
            'submitted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return FormSubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit form: $e');
    }
  }

  /// Approve form (unit head action)
  Future<FormSubmissionModel> approveForm(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update form status
      final response = await _supabase
          .from('form_submissions')
          .update({
            'status': AppConstants.statusApproved,
            'reviewed_by': userId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select('''
            *,
            resident:residents(first_name, last_name),
            submitter:profiles!form_submissions_submitted_by_fkey(full_name, signature_url),
            reviewer:profiles!form_submissions_reviewed_by_fkey(full_name, signature_url)
          ''')
          .single();

      final form = FormSubmissionModel.fromJson(response);

      // Create timeline entry
      await _createTimelineEntry(
        residentId: form.residentId,
        entryType: 'form',
        formSubmissionId: form.id,
        formTemplateType: form.templateType,
        unit: form.unit,
        title: form.templateDisplayName,
        description: 'Form approved by ${form.reviewerName ?? 'Unit Head'}',
        createdBy: userId,
      );

      return form;
    } catch (e) {
      throw Exception('Failed to approve form: $e');
    }
  }

  /// Return form (unit head action)
  Future<FormSubmissionModel> returnForm({
    required String id,
    required String comment,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('form_submissions')
          .update({
            'status': AppConstants.statusReturned,
            'reviewed_by': userId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'review_comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return FormSubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to return form: $e');
    }
  }

  /// Create timeline entry (internal)
  Future<void> _createTimelineEntry({
    required String residentId,
    required String entryType,
    String? formSubmissionId,
    String? formTemplateType,
    required String unit,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
    required String createdBy,
  }) async {
    await _supabase.from('timeline_entries').insert({
      'resident_id': residentId,
      'entry_type': entryType,
      'form_submission_id': formSubmissionId,
      'form_template_type': formTemplateType,
      'unit': unit,
      'title': title,
      'description': description,
      'metadata': metadata,
      'created_by': createdBy,
    });
  }

  /// Get timeline entries for a resident
  Future<List<TimelineEntryModel>> getTimeline({
    required String residentId,
    String? unit,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      var query = _supabase
          .from('timeline_entries')
          .select('''
            *,
            creator:profiles(full_name)
          ''')
          .eq('resident_id', residentId);

      if (unit != null) {
        query = query.eq('unit', unit);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      
      return response.map((json) => TimelineEntryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch timeline: $e');
    }
  }

  /// Subscribe to realtime timeline updates
  RealtimeChannel subscribeToTimeline(
    String residentId,
    void Function(TimelineEntryModel entry) onNewEntry,
  ) {
    return _supabase
        .channel('timeline:$residentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'timeline_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'resident_id',
            value: residentId,
          ),
          callback: (payload) {
            final entry = TimelineEntryModel.fromJson(payload.newRecord);
            onNewEntry(entry);
          },
        )
        .subscribe();
  }
}
