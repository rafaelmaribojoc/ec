import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/form_approval_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

/// Helper function to convert empty strings to null for UUID fields
String? _nullIfEmpty(String? value) => (value?.isEmpty ?? true) ? null : value;

/// Repository for managing form approvals and notifications
class ApprovalRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================================
  // APPROVAL REQUESTS
  // ============================================================================

  /// Get all pending approvals for the current user
  Future<List<FormApprovalModel>> getPendingApprovals() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('form_approvals')
        .select()
        .eq('recipient_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FormApprovalModel.fromJson(json))
        .toList();
  }

  /// Get all approvals sent by the current user
  Future<List<FormApprovalModel>> getSentApprovals() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('form_approvals')
        .select()
        .eq('sender_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FormApprovalModel.fromJson(json))
        .toList();
  }

  /// Get approvals for a specific form
  Future<List<FormApprovalModel>> getFormApprovals(String formId) async {
    final response = await _supabase
        .from('form_approvals')
        .select()
        .eq('form_submission_id', formId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FormApprovalModel.fromJson(json))
        .toList();
  }

  /// Create an approval request
  Future<FormApprovalModel> createApprovalRequest({
    required String formId,
    required String recipientId,
    required String recipientName,
    String? signatureFieldName,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Validate required UUID fields - convert empty strings to null and check
    final safeFormId = _nullIfEmpty(formId);
    final safeRecipientId = _nullIfEmpty(recipientId);
    
    if (safeFormId == null) {
      throw Exception('Invalid form ID: cannot be empty');
    }
    if (safeRecipientId == null) {
      throw Exception('Invalid recipient ID: cannot be empty');
    }

    // Get sender's name
    final senderProfile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', userId)
        .single();

    final senderName = senderProfile['full_name'] as String;

    // Create approval request
    final response = await _supabase
        .from('form_approvals')
        .insert({
          'form_submission_id': safeFormId,
          'sender_id': userId,
          'sender_name': senderName,
          'recipient_id': safeRecipientId,
          'recipient_name': recipientName,
          'signature_field_name': _nullIfEmpty(signatureFieldName),
          'status': 'pending',
        })
        .select()
        .single();

    // Update form status to pending_review
    await _supabase.from('form_submissions').update({
      'status': 'pending_review',
      'submitted_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', formId);

    // Create notification for recipient
    await createNotification(
      userId: recipientId,
      type: 'approval_request',
      title: 'New Form Approval Request',
      message: '$senderName has submitted a form for your review.',
      formSubmissionId: formId,
      formApprovalId: response['id'] as String,
    );

    return FormApprovalModel.fromJson(response);
  }

  /// Approve a form
  Future<void> approveForm({
    required String approvalId,
    String? signatureUrl,
    String? comment,
  }) async {
    final approval = await _supabase
        .from('form_approvals')
        .select()
        .eq('id', approvalId)
        .single();

    // Update approval
    await _supabase.from('form_approvals').update({
      'status': 'approved',
      'action_at': DateTime.now().toIso8601String(),
      'signature_url': signatureUrl,
      'signature_applied':
          signatureUrl != null || approval['signature_field_name'] != null,
      'comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', approvalId);

    // Update form
    final formId = approval['form_submission_id'] as String;
    final recipientId = approval['recipient_id'] as String;
    final recipientName = approval['recipient_name'] as String;

    await _supabase.from('form_submissions').update({
      'status': 'approved',
      'reviewed_by': recipientId,
      'reviewed_at': DateTime.now().toIso8601String(),
      'review_comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', formId);

    // If signature field is specified, add to form_signatures
    final signatureFieldName = approval['signature_field_name'] as String?;
    if (signatureFieldName != null && signatureUrl != null) {
      await _supabase.from('form_signatures').upsert({
        'form_submission_id': formId,
        'signer_id': recipientId,
        'signer_name': recipientName,
        'field_name': signatureFieldName,
        'signature_url': signatureUrl,
        'signed_at': DateTime.now().toIso8601String(),
        'is_auto_applied': false,
      }, onConflict: 'form_submission_id, field_name');
    }

    // Notify sender
    final senderId = approval['sender_id'] as String;
    await createNotification(
      userId: senderId,
      type: 'form_approved',
      title: 'Form Approved',
      message: '$recipientName has approved your form submission.',
      formSubmissionId: formId,
      formApprovalId: approvalId,
    );
  }

  /// Acknowledge a form (without signature)
  Future<void> acknowledgeForm({
    required String approvalId,
    String? comment,
  }) async {
    final approval = await _supabase
        .from('form_approvals')
        .select()
        .eq('id', approvalId)
        .single();

    // Update approval
    await _supabase.from('form_approvals').update({
      'status': 'acknowledged',
      'action_at': DateTime.now().toIso8601String(),
      'comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', approvalId);

    // Notify sender
    final senderId = approval['sender_id'] as String;
    final recipientName = approval['recipient_name'] as String;
    final formId = approval['form_submission_id'] as String;

    await createNotification(
      userId: senderId,
      type: 'form_acknowledged',
      title: 'Form Acknowledged',
      message: '$recipientName has acknowledged your form submission.',
      formSubmissionId: formId,
      formApprovalId: approvalId,
    );
  }

  /// Return a form for revisions
  Future<void> returnForm({
    required String approvalId,
    required String comment,
  }) async {
    final approval = await _supabase
        .from('form_approvals')
        .select()
        .eq('id', approvalId)
        .single();

    // Update approval
    await _supabase.from('form_approvals').update({
      'status': 'returned',
      'action_at': DateTime.now().toIso8601String(),
      'comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', approvalId);

    // Update form status
    final formId = approval['form_submission_id'] as String;
    final recipientId = approval['recipient_id'] as String;

    await _supabase.from('form_submissions').update({
      'status': 'returned',
      'reviewed_by': recipientId,
      'reviewed_at': DateTime.now().toIso8601String(),
      'review_comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', formId);

    // Notify sender
    final senderId = approval['sender_id'] as String;
    final recipientName = approval['recipient_name'] as String;

    await createNotification(
      userId: senderId,
      type: 'form_returned',
      title: 'Form Returned',
      message: '$recipientName has returned your form for revisions: $comment',
      formSubmissionId: formId,
      formApprovalId: approvalId,
    );
  }

  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================

  /// Get all notifications for the current user
  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _supabase.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Create a notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? formSubmissionId,
    String? formApprovalId,
    Map<String, dynamic>? metadata,
  }) async {
    // Convert empty strings to null for UUID fields
    final safeFormSubmissionId = (formSubmissionId?.isEmpty ?? true) ? null : formSubmissionId;
    final safeFormApprovalId = (formApprovalId?.isEmpty ?? true) ? null : formApprovalId;
    final safeUserId = userId.isEmpty ? null : userId;
    
    if (safeUserId == null) {
      debugPrint('Cannot create notification: userId is empty');
      return;
    }
    
    await _supabase.from('notifications').insert({
      'user_id': safeUserId,
      'type': type,
      'title': title,
      'message': message,
      'form_submission_id': safeFormSubmissionId,
      'form_approval_id': safeFormApprovalId,
      'metadata': metadata ?? {},
    });
  }

  // ============================================================================
  // USERS (for recipient selection)
  // ============================================================================

  /// Get all users that can be selected as recipients
  Future<List<UserModel>> getApprovalRecipients({String? excludeUserId}) async {
    var query = _supabase
        .from('profiles')
        .select()
        .eq('is_active', true)
        .inFilter('role', [
      'head',
      'center_head',
      'super_admin',
      'social_head',
      'medical_head',
      'psych_head',
      'rehab_head',
      'homelife_head'
    ]);

    final response = await query.order('full_name');

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .where((user) => excludeUserId == null || user.id != excludeUserId)
        .toList();
  }

  /// Get users in a specific unit
  Future<List<UserModel>> getUsersByUnit(String unit) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('is_active', true)
        .eq('unit', unit)
        .order('full_name');

    return (response as List).map((json) => UserModel.fromJson(json)).toList();
  }

  // ============================================================================
  // SIGNATURES
  // ============================================================================

  /// Auto-apply creator's signature to "Prepared By" field
  Future<void> applyPreparedBySignature({
    required String formId,
    required String userId,
    required String userName,
    required String signatureUrl,
    String? title,
    String? employeeId,
  }) async {
    await _supabase.from('form_signatures').upsert({
      'form_submission_id': formId,
      'signer_id': userId,
      'signer_name': userName,
      'signer_title': title,
      'signer_employee_id': employeeId,
      'field_name': 'prepared_by',
      'field_label': 'Prepared By',
      'signature_url': signatureUrl,
      'is_auto_applied': true,
    }, onConflict: 'form_submission_id, field_name');

    // Also update the form submission
    await _supabase.from('form_submissions').update({
      'prepared_by_id': userId,
      'prepared_by_name': userName,
      'prepared_by_signature_url': signatureUrl,
      'prepared_at': DateTime.now().toIso8601String(),
    }).eq('id', formId);
  }

  /// Get all signatures for a form
  Future<List<Map<String, dynamic>>> getFormSignatures(String formId) async {
    final response = await _supabase
        .from('form_signatures')
        .select()
        .eq('form_submission_id', formId)
        .order('signed_at');

    return List<Map<String, dynamic>>.from(response);
  }
}
