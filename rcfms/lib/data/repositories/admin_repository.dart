import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/ward_model.dart';
import '../../core/constants/supabase_config.dart';

/// Repository for admin operations
class AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[AdminRepository] $message');
    }
  }

  /// Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Provision new user directly via Supabase Auth REST API
  /// 
  /// Returns the created user and temporary password
  Future<({UserModel user, String tempPassword})> provisionUser({
    required String email,
    required String fullName,
    required String workId,
    required String role,
    String? unit,
  }) async {
    try {
      _log('Provisioning new user: $email');
      
      // Check if email already exists
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        _log('User already exists with email: $email');
        throw Exception('A user with this email already exists');
      }

      // Generate a simple temporary password (easy to type on mobile)
      final tempPassword = 'Welcome123!';
      _log('Creating auth user via Admin API...');

      // Call Supabase Admin API to create user (using service role key)
      final response = await http.post(
        Uri.parse('${SupabaseConfig.url}/auth/v1/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.serviceRoleKey,
          'Authorization': 'Bearer ${SupabaseConfig.serviceRoleKey}',
        },
        body: jsonEncode({
          'email': email,
          'password': tempPassword,
          'email_confirm': true, // Auto-confirm email
          'user_metadata': {
            'full_name': fullName,
            'work_id': workId,
            'role': role,
            'unit': unit,
          },
        }),
      );

      final authData = jsonDecode(response.body) as Map<String, dynamic>;
      _log('Auth API response status: ${response.statusCode}');
      
      // Check for errors
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = authData['msg'] ?? 
                         authData['error_description'] ?? 
                         authData['message'] ??
                         authData['error'] ??
                         'Failed to create user (${response.statusCode})';
        _log('Auth API error: $errorMsg');
        throw Exception(errorMsg);
      }

      final userId = authData['id'] as String;
      _log('Auth user created with ID: $userId');

      // Update the profile with role and unit using service role key (bypasses RLS)
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for trigger
      _log('Upserting profile for user: $userId');
      
      final profileUpdateResponse = await http.post(
        Uri.parse('${SupabaseConfig.url}/rest/v1/profiles'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.serviceRoleKey,
          'Authorization': 'Bearer ${SupabaseConfig.serviceRoleKey}',
          'Prefer': 'resolution=merge-duplicates,return=representation',
        },
        body: jsonEncode({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'work_id': workId,
          'role': role,
          'unit': unit,
          'is_active': true,
        }),
      );

      _log('Profile upsert response: ${profileUpdateResponse.statusCode}');
      if (profileUpdateResponse.statusCode != 200 && profileUpdateResponse.statusCode != 201) {
        _log('Profile update warning: ${profileUpdateResponse.body}');
      }

      // Fetch the created user profile using service role
      final profileGetResponse = await http.get(
        Uri.parse('${SupabaseConfig.url}/rest/v1/profiles?id=eq.$userId&select=*'),
        headers: {
          'apikey': SupabaseConfig.serviceRoleKey,
          'Authorization': 'Bearer ${SupabaseConfig.serviceRoleKey}',
        },
      );
      
      final profiles = jsonDecode(profileGetResponse.body) as List;
      final profileData = profiles.isNotEmpty 
          ? profiles.first as Map<String, dynamic>
          : {
              'id': userId,
              'email': email,
              'full_name': fullName,
              'work_id': workId,
              'role': role,
              'unit': unit,
              'is_active': true,
            };

      _log('User provisioned successfully: $email');
      return (
        user: UserModel.fromJson(profileData),
        tempPassword: tempPassword,
      );
    } catch (e) {
      _log('Failed to provision user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update an existing user's profile
  Future<UserModel> updateUserProfile({
    required String userId,
    required String fullName,
    required String workId,
    required String role,
    String? unit,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'full_name': fullName,
            'work_id': workId,
            'role': role,
            'unit': unit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to reactivate user: $e');
    }
  }

  /// Update user role
  Future<UserModel> updateUserRole({
    required String userId,
    required String role,
    String? unit,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'role': role,
            'unit': unit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Get all wards
  Future<List<WardModel>> getAllWards() async {
    try {
      final response = await _supabase
          .from('wards')
          .select()
          .order('name', ascending: true);

      return response.map((json) => WardModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wards: $e');
    }
  }

  /// Create ward
  Future<WardModel> createWard({
    required String name,
    String? description,
    String? nfcTagId,
    int? capacity,
    String? floor,
    String? building,
  }) async {
    try {
      final response = await _supabase
          .from('wards')
          .insert({
            'name': name,
            'description': description,
            'nfc_tag_id': nfcTagId,
            'capacity': capacity ?? 0,
            'floor': floor,
            'building': building,
          })
          .select()
          .single();

      return WardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create ward: $e');
    }
  }

  /// Update ward
  Future<WardModel> updateWard({
    required String id,
    String? name,
    String? description,
    String? nfcTagId,
    int? capacity,
    String? floor,
    String? building,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (nfcTagId != null) updates['nfc_tag_id'] = nfcTagId;
      if (capacity != null) updates['capacity'] = capacity;
      if (floor != null) updates['floor'] = floor;
      if (building != null) updates['building'] = building;

      final response = await _supabase
          .from('wards')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return WardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update ward: $e');
    }
  }

  /// Assign NFC tag to ward
  Future<WardModel> assignNfcTag({
    required String wardId,
    required String nfcTagId,
  }) async {
    try {
      // Check if NFC tag is already assigned to another ward
      final existing = await _supabase
          .from('wards')
          .select('id')
          .eq('nfc_tag_id', nfcTagId)
          .maybeSingle();

      if (existing != null && existing['id'] != wardId) {
        throw Exception('This NFC tag is already assigned to another ward');
      }

      final response = await _supabase
          .from('wards')
          .update({
            'nfc_tag_id': nfcTagId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', wardId)
          .select()
          .single();

      return WardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to assign NFC tag: $e');
    }
  }

  /// Delete ward (soft delete)
  Future<void> deleteWard(String id) async {
    try {
      await _supabase.from('wards').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete ward: $e');
    }
  }

  /// Get audit logs
  Future<List<Map<String, dynamic>>> getAuditLogs({
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final response = await _supabase
          .from('audit_logs')
          .select()
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch audit logs: $e');
    }
  }

  /// Get facility statistics
  Future<Map<String, dynamic>> getFacilityStats() async {
    try {
      final residentsCount = await _supabase
          .from('residents')
          .select('id')
          .eq('is_active', true)
          .count();

      final wardsCount = await _supabase
          .from('wards')
          .select('id')
          .eq('is_active', true)
          .count();

      final usersCount = await _supabase
          .from('profiles')
          .select('id')
          .eq('is_active', true)
          .count();

      final pendingForms = await _supabase
          .from('form_submissions')
          .select('id')
          .eq('status', 'pending_review')
          .count();

      return {
        'total_residents': residentsCount.count,
        'total_wards': wardsCount.count,
        'total_users': usersCount.count,
        'pending_forms': pendingForms.count,
      };
    } catch (e) {
      throw Exception('Failed to fetch facility stats: $e');
    }
  }
}
