/// Supabase configuration constants
/// Replace these with your actual Supabase project credentials
class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase project URL
  /// Format: https://[project-ref].supabase.co
  static const String url = 'https://riikouenozsqofqvloqe.supabase.co';

  /// Your Supabase anon/public key
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpaWtvdWVub3pzcW9mcXZsb3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NzI3ODgsImV4cCI6MjA4MzQ0ODc4OH0.Pb3yTN9sHIjEfxjeIKZtEBly-uuyH-E3ILuyweQ5aAs';

  /// Service role key for admin operations (DEVELOPMENT ONLY!)
  /// WARNING: Never expose this in production apps!
  static const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpaWtvdWVub3pzcW9mcXZsb3FlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzg3Mjc4OCwiZXhwIjoyMDgzNDQ4Nzg4fQ.2jdQB7Vyi3Bo9P-qe6_E1BY210udNUXk45UHxMbUi4A';

  /// Backend API URL for admin operations
  /// Use your computer's IP address for mobile device access
  static const String backendUrl = 'http://192.168.1.9:3000/api';

  /// Storage bucket names
  static const String signaturesBucket = 'signatures';
  static const String residentPhotosBucket = 'resident_photos';
  static const String documentsBucket = 'documents';
}
