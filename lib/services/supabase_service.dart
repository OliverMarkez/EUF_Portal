import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // Authentication methods using Supabase auth + staff table
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  static Future<Map<String, dynamic>?> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      print('Looking up username: $username in staff table');

      // First find the user by username in staff table
      final staffData = await client
          .from('staff')
          .select()
          .eq('username', username)
          .single();

      print('Found staff data: found');

      final email = staffData['email'] as String?;
      if (email == null) {
        print('Email is null in staff data');
        throw Exception('Invalid username or password');
      }
      print('Attempting auth with email: $email');

      // Then authenticate with Supabase auth using the email
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print(
        'Auth response: ${authResponse.user != null ? 'Success' : 'Failed'}',
      );

      if (authResponse.user != null) {
        // Combine auth user data with staff data
        return {
          'id': authResponse.user!.id,
          'email': authResponse.user!.email,
          'username': staffData['username'] as String,
          'email_staff': staffData['email'] as String,
          // Add any other fields from your staff table
        };
      } else {
        // Password is incorrect
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      print('Error in signInWithUsername: $e');
      if (e.toString().contains('Invalid username or password')) {
        rethrow;
      }
      // For other errors (network, etc.), return null
      return null;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  static Stream<User?> get authStateChanges =>
      client.auth.onAuthStateChange.map((data) => data.session?.user);

  // Database methods
  static SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  // Storage methods
  static SupabaseStorageClient get storage => client.storage;
}
