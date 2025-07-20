import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated {
    final authenticated = _currentUser != null;
    print(
      'isAuthenticated check: $authenticated, currentUser: ${_currentUser?['username'] ?? 'null'}',
    );
    return authenticated;
  }

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    SupabaseService.authStateChanges.listen((User? user) {
      print('Auth state changed: ${user?.email ?? 'null'}');
      if (user != null) {
        // Only fetch staff data if we don't already have user data
        if (_currentUser == null || _currentUser!['id'] != user.id) {
          _fetchStaffData(user.id);
        }
      } else {
        print('User logged out, clearing current user');
        _currentUser = null;
        // Don't clear error here - let the UI handle it
        notifyListeners();
      }
    });
  }

  Future<void> _fetchStaffData(String userId) async {
    try {
      final staffData = await SupabaseService.client
          .from('staff')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = {
        'id': userId,
        'email': SupabaseService.currentUser?.email,
        'username': staffData['username'],
        'email_staff': staffData['email'],
      };
      notifyListeners();
    } catch (e) {
      print('Error fetching staff data: $e');
    }
  }

  Future<bool> signIn(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting to sign in with username: $username');

      final user = await SupabaseService.signInWithUsername(
        username: username,
        password: password,
      );

      print('Sign in result: ${user != null ? 'Success' : 'Failed'}');

      if (user != null) {
        _currentUser = user;
        print('User authenticated: ${user['username']}');
        notifyListeners(); // Ensure UI updates immediately
        return true;
      } else {
        _error = 'Invalid username or password';
        print('Authentication failed: $_error');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('Invalid username or password')) {
        _error = 'Invalid username or password';
      } else {
        _error = 'An error occurred. Please try again.';
      }
      print('Authentication error: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Signing out user: ${_currentUser?['username']}');
      await SupabaseService.signOut();

      // Force clear the current user immediately
      _currentUser = null;
      _error = null;
      print('User signed out successfully');

      // Ensure UI updates immediately
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Sign out error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
