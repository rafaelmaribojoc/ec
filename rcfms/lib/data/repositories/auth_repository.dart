import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/supabase_config.dart';

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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
      print('DEBUG SIGNIN: Attempting login for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('DEBUG SIGNIN: Auth response received');
      print('DEBUG SIGNIN: User: ${response.user?.id}');
      print('DEBUG SIGNIN: Session: ${response.session != null}');

      if (response.user == null) {
        throw Exception('Login failed. Please check your credentials.');
      }

      // Fetch user profile
      print('DEBUG SIGNIN: Fetching profile for user: ${response.user!.id}');
      final profile = await getUserProfile(response.user!.id);
      print('DEBUG SIGNIN: Profile fetched successfully: ${profile.email}');
      return profile;
    } on AuthException catch (e) {
      print('DEBUG SIGNIN: AuthException: ${e.message}');
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      print('DEBUG SIGNIN: PostgrestException: code=${e.code}, message=${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('DEBUG SIGNIN: General error: $e');
      throw Exception('An error occurred during sign in: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get user profile from profiles table
  Future<UserModel> getUserProfile(String userId) async {
    try {
      print('DEBUG: Fetching profile for userId: $userId');
      
      // First try by ID
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print('DEBUG: Profile found by ID: $response');
        return UserModel.fromJson(response);
      }
      
      // If not found by ID, try by email from auth user
      final authUser = _supabase.auth.currentUser;
      if (authUser?.email != null) {
        print('DEBUG: Profile not found by ID, trying by email: ${authUser!.email}');
        final emailResponse = await _supabase
            .from('profiles')
            .select()
            .eq('email', authUser.email!)
            .maybeSingle();
            
        if (emailResponse != null) {
          print('DEBUG: Profile found by email: $emailResponse');
          return UserModel.fromJson(emailResponse);
        }
      }
      
      // No profile found - create a basic one
      print('DEBUG: No profile found, creating basic profile');
      throw Exception('Profile not found. Please contact administrator.');
    } on PostgrestException catch (e) {
      print('DEBUG: PostgrestException - code: ${e.code}, message: ${e.message}, details: ${e.details}, hint: ${e.hint}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('DEBUG: General error: $e');
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
