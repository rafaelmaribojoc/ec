import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/supabase_config.dart';

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[AuthRepository] $message');
    }
  }

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _log('Attempting login for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _log('Auth response received - User ID: ${response.user?.id}, Session: ${response.session != null}');

      if (response.user == null) {
        throw Exception('Login failed. Please check your credentials.');
      }

      // Fetch user profile - may need to be created if trigger didn't work
      _log('Fetching profile for user: ${response.user!.id}');
      UserModel profile;
      try {
        profile = await getUserProfile(response.user!.id);
        _log('Profile fetched successfully: ${profile.email}');
      } catch (e) {
        _log('Profile not found, attempting to create one: $e');
        // Profile doesn't exist - create it from auth user metadata
        profile = await _createProfileFromAuthUser(response.user!);
        _log('Profile created successfully');
      }
      return profile;
    } on AuthException catch (e) {
      _log('AuthException: ${e.message}');
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      _log('PostgrestException: code=${e.code}, message=${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      _log('General error during sign in: $e');
      throw Exception('An error occurred during sign in: $e');
    }
  }

  /// Create profile from auth user if trigger didn't work
  Future<UserModel> _createProfileFromAuthUser(User authUser) async {
    _log('Creating profile from auth user metadata');
    final metadata = authUser.userMetadata ?? {};
    
    final profileData = {
      'id': authUser.id,
      'email': authUser.email ?? '',
      'full_name': metadata['full_name'] ?? 'New User',
      'work_id': metadata['work_id'] ?? 'TEMP-${authUser.id.substring(0, 8)}',
      'role': metadata['role'] ?? 'social_staff',
      'unit': metadata['unit'],
      'is_active': true,
    };

    try {
      await _supabase.from('profiles').upsert(profileData);
      _log('Profile upserted successfully');
      return UserModel.fromJson(profileData);
    } catch (e) {
      _log('Failed to create profile: $e');
      // Return a temporary model if upsert fails
      return UserModel.fromJson(profileData);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _log('Signing out user...');
    try {
      await _supabase.auth.signOut();
      _log('Sign out successful');
    } catch (e) {
      _log('Sign out error: $e');
      // Force clear session even on error
      rethrow;
    }
  }

  /// Get user profile from profiles table
  Future<UserModel> getUserProfile(String userId) async {
    try {
      _log('Fetching profile for userId: $userId');
      
      // First try by ID
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _log('Profile found by ID');
        return UserModel.fromJson(response);
      }
      
      // If not found by ID, try by email from auth user
      final authUser = _supabase.auth.currentUser;
      if (authUser?.email != null) {
        _log('Profile not found by ID, trying by email: ${authUser!.email}');
        final emailResponse = await _supabase
            .from('profiles')
            .select()
            .eq('email', authUser.email!)
            .maybeSingle();
            
        if (emailResponse != null) {
          _log('Profile found by email');
          return UserModel.fromJson(emailResponse);
        }
        
        // No profile found but user is authenticated - create profile using existing method
        _log('No profile found, creating one for authenticated user');
        return _createProfileFromAuthUser(authUser);
      }
      
      // No profile found and no auth user email
      _log('No profile found for user');
      throw Exception('Profile not found. Please contact administrator.');
    } on PostgrestException catch (e) {
      _log('PostgrestException - code: ${e.code}, message: ${e.message}, details: ${e.details}, hint: ${e.hint}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      _log('General error in getUserProfile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? username,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;

      await _supabase.from('profiles').update(updates).eq('id', userId);

      return getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Upload signature
  Future<String> uploadSignature({
    required String userId,
    required Uint8List signatureBytes,
  }) async {
    try {
      final fileName = '$userId/signature.png';
      
      await _supabase.storage.from(SupabaseConfig.signaturesBucket).uploadBinary(
        fileName,
        signatureBytes,
        fileOptions: const FileOptions(
          contentType: 'image/png',
          upsert: true,
        ),
      );

      final signatureUrl = _supabase.storage
          .from(SupabaseConfig.signaturesBucket)
          .getPublicUrl(fileName);

      // Update profile with signature URL
      await _supabase.from('profiles').update({
        'signature_url': signatureUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return signatureUrl;
    } catch (e) {
      throw Exception('Failed to upload signature: $e');
    }
  }

  /// Check if current user has a signature
  Future<bool> hasSignature() async {
    final userId = currentUserId;
    if (userId == null) return false;

    final profile = await getUserProfile(userId);
    return profile.signatureUrl != null && profile.signatureUrl!.isNotEmpty;
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return getUserProfile(userId);
  }
}
