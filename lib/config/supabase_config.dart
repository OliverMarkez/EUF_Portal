class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  static const String url =
      'https://aqcoewhsvficpxkoykte.supabase.co'; // Replace with your actual project URL
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxY29ld2hzdmZpY3B4a295a3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NDY0NDIsImV4cCI6MjA2ODQyMjQ0Mn0.Dq6Qxk9NEU1GIpxsKG0E_NITLZgHsb0JosLCEqgXLPY'; // Replace with your actual anon key

  // Example format:
  // static const String url = 'https://your-project.supabase.co';
  // static const String anonKey = 'your-anon-key-here';

  // Also update the table name in SupabaseService.dart to match your table name
  // Default is 'staff' - change it to your actual table name
}
