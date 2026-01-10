import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resident_model.dart';
import '../models/ward_model.dart';
import '../../core/constants/supabase_config.dart';
import '../../core/constants/app_constants.dart';

/// Repository for resident operations
class ResidentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[ResidentRepository] $message');
    }
  }

  /// Get all residents
  Future<List<ResidentModel>> getResidents({
    String? wardId,
    String? searchQuery,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      _log('Fetching residents - wardId: $wardId, searchQuery: $searchQuery, page: $page');
      
      var query = _supabase
          .from('residents')
          .select('*, ward:wards(name)')
          .eq('is_active', true);

      if (wardId != null) {
        query = query.eq('ward_id', wardId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'first_name.ilike.%$searchQuery%,last_name.ilike.%$searchQuery%',
        );
      }

      final response = await query
          .order('last_name', ascending: true)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      
      _log('Fetched ${response.length} residents');
      return response.map((json) => ResidentModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      _log('PostgrestException - code: ${e.code}, message: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      _log('Error fetching residents: $e');
      throw Exception('Failed to fetch residents: $e');
    }
  }

  /// Get resident by ID
  Future<ResidentModel> getResidentById(String id) async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, ward:wards(name)')
          .eq('id', id)
          .single();

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch resident: $e');
    }
  }

  /// Get residents by ward ID (for NFC scan)
  Future<List<ResidentModel>> getResidentsByWardId(String wardId) async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, ward:wards(name)')
          .eq('ward_id', wardId)
          .eq('is_active', true)
          .order('last_name', ascending: true);

      return response.map((json) => ResidentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch residents for ward: $e');
    }
  }

  /// Add new resident
  Future<ResidentModel> addResident({
    required String firstName,
    required String lastName,
    String? middleName,
    required DateTime dateOfBirth,
    required String gender,
    required String wardId,
    String? roomNumber,
    String? bedNumber,
    required DateTime admissionDate,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? medicalNotes,
    String? allergies,
    String? primaryDiagnosis,
    Uint8List? photoBytes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      String? photoUrl;
      
      // Upload photo if provided
      if (photoBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage
            .from(SupabaseConfig.residentPhotosBucket)
            .uploadBinary(
              fileName,
              photoBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        photoUrl = _supabase.storage
            .from(SupabaseConfig.residentPhotosBucket)
            .getPublicUrl(fileName);
      }

      final response = await _supabase
          .from('residents')
          .insert({
            'first_name': firstName,
            'last_name': lastName,
            'middle_name': middleName,
            'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
            'gender': gender,
            'ward_id': wardId,
            'room_number': roomNumber,
            'bed_number': bedNumber,
            'admission_date': admissionDate.toIso8601String().split('T').first,
            'emergency_contact_name': emergencyContactName,
            'emergency_contact_phone': emergencyContactPhone,
            'emergency_contact_relation': emergencyContactRelation,
            'medical_notes': medicalNotes,
            'allergies': allergies,
            'primary_diagnosis': primaryDiagnosis,
            'photo_url': photoUrl,
            'created_by': userId,
          })
          .select('*, ward:wards(name)')
          .single();

      // Update ward occupancy
      await _supabase.rpc('increment_ward_occupancy', params: {
        'ward_id_param': wardId,
      });

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add resident: $e');
    }
  }

  /// Update resident
  Future<ResidentModel> updateResident({
    required String id,
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? dateOfBirth,
    String? gender,
    String? wardId,
    String? roomNumber,
    String? bedNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? medicalNotes,
    String? allergies,
    String? primaryDiagnosis,
    Uint8List? photoBytes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (middleName != null) updates['middle_name'] = middleName;
      if (dateOfBirth != null) {
        updates['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
      }
      if (gender != null) updates['gender'] = gender;
      if (wardId != null) updates['ward_id'] = wardId;
      if (roomNumber != null) updates['room_number'] = roomNumber;
      if (bedNumber != null) updates['bed_number'] = bedNumber;
      if (emergencyContactName != null) {
        updates['emergency_contact_name'] = emergencyContactName;
      }
      if (emergencyContactPhone != null) {
        updates['emergency_contact_phone'] = emergencyContactPhone;
      }
      if (emergencyContactRelation != null) {
        updates['emergency_contact_relation'] = emergencyContactRelation;
      }
      if (medicalNotes != null) updates['medical_notes'] = medicalNotes;
      if (allergies != null) updates['allergies'] = allergies;
      if (primaryDiagnosis != null) {
        updates['primary_diagnosis'] = primaryDiagnosis;
      }

      // Upload new photo if provided
      if (photoBytes != null) {
        final fileName = '$id/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage
            .from(SupabaseConfig.residentPhotosBucket)
            .uploadBinary(
              fileName,
              photoBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        updates['photo_url'] = _supabase.storage
            .from(SupabaseConfig.residentPhotosBucket)
            .getPublicUrl(fileName);
      }

      final response = await _supabase
          .from('residents')
          .update(updates)
          .eq('id', id)
          .select('*, ward:wards(name)')
          .single();

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update resident: $e');
    }
  }

  /// Discharge resident (soft delete)
  Future<void> dischargeResident(String id) async {
    try {
      final resident = await getResidentById(id);
      
      await _supabase.from('residents').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // Update ward occupancy
      await _supabase.rpc('decrement_ward_occupancy', params: {
        'ward_id_param': resident.wardId,
      });
    } catch (e) {
      throw Exception('Failed to discharge resident: $e');
    }
  }

  /// Search residents with full text search
  Future<List<ResidentModel>> searchResidents(String query) async {
    try {
      final response = await _supabase
          .from('residents')
          .select('*, ward:wards(name)')
          .eq('is_active', true)
          .textSearch('fts', query)
          .limit(20);

      return response.map((json) => ResidentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search residents: $e');
    }
  }

  /// Get all wards
  Future<List<WardModel>> getWards() async {
    try {
      final response = await _supabase
          .from('wards')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map((json) => WardModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wards: $e');
    }
  }

  /// Get ward by NFC tag ID
  Future<WardModel?> getWardByNfcTag(String nfcTagId) async {
    try {
      final response = await _supabase
          .from('wards')
          .select()
          .eq('nfc_tag_id', nfcTagId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return WardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch ward by NFC tag: $e');
    }
  }
}
