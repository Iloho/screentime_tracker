import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<SupabaseClient> get _client async => await _supabaseService.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final client = await _client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final client = await _client;
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  // Check if authenticated
  bool isAuthenticated() {
    return _supabaseService.isAuthenticated;
  }

  // Auth state changes stream
  Stream<AuthState> get authStateChanges {
    return _supabaseService.authStateChanges;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final client = await _client;
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final client = await _client;
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      await client.from('user_profiles').update(updates).eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }
}
