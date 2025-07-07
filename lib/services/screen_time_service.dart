import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class ScreenTimeService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<SupabaseClient> get _client async => await _supabaseService.client;

  // Record screen session
  Future<void> recordScreenSession({
    required String appName,
    String? appPackage,
    required String appCategory,
    required DateTime sessionStart,
    DateTime? sessionEnd,
    int? durationMinutes,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await client.from('screen_sessions').insert({
        'user_id': user.id,
        'app_name': appName,
        'app_package': appPackage,
        'app_category': appCategory,
        'session_start': sessionStart.toIso8601String(),
        'session_end': sessionEnd?.toIso8601String(),
        'duration_minutes': durationMinutes,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'sync_status': 'synced',
      });
    } catch (error) {
      throw Exception('Failed to record screen session: $error');
    }
  }

  // Get today's screen sessions
  Future<List<Map<String, dynamic>>> getTodayScreenSessions() async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await client
          .from('screen_sessions')
          .select()
          .eq('user_id', user.id)
          .gte('session_start', startOfDay.toIso8601String())
          .lt('session_start', endOfDay.toIso8601String())
          .order('session_start', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get screen sessions: $error');
    }
  }

  // Get daily statistics
  Future<Map<String, dynamic>> getDailyStats({DateTime? date}) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final targetDate = date ?? DateTime.now();
      final dateString =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final response = await client.rpc('get_user_daily_stats', params: {
        'target_date': dateString,
      });

      if (response.isNotEmpty) {
        return response[0];
      }

      return {
        'total_screen_time_minutes': 0,
        'total_sessions': 0,
        'total_notifications': 0,
        'most_used_app': null,
        'most_used_category': null,
      };
    } catch (error) {
      throw Exception('Failed to get daily stats: $error');
    }
  }

  // Get collection stats
  Future<Map<String, dynamic>?> getCollectionStats({DateTime? date}) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final targetDate = date ?? DateTime.now();
      final dateString =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('collection_stats')
          .select()
          .eq('user_id', user.id)
          .eq('date', dateString)
          .single();

      return response;
    } catch (error) {
      // Return null if no stats found for the date
      return null;
    }
  }

  // Update collection stats
  Future<void> updateCollectionStats({
    required DateTime date,
    int? totalScreenTimeMinutes,
    int? totalSessions,
    int? totalNotifications,
    int? locationPoints,
    bool? isCollectionActive,
  }) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final updateData = <String, dynamic>{
        'last_sync_at': DateTime.now().toIso8601String(),
      };

      if (totalScreenTimeMinutes != null) {
        updateData['total_screen_time_minutes'] = totalScreenTimeMinutes;
      }
      if (totalSessions != null) {
        updateData['total_sessions'] = totalSessions;
      }
      if (totalNotifications != null) {
        updateData['total_notifications'] = totalNotifications;
      }
      if (locationPoints != null) {
        updateData['location_points'] = locationPoints;
      }
      if (isCollectionActive != null) {
        updateData['is_collection_active'] = isCollectionActive;
      }

      await client.from('collection_stats').upsert({
        'user_id': user.id,
        'date': dateString,
        ...updateData,
      });
    } catch (error) {
      throw Exception('Failed to update collection stats: $error');
    }
  }

  // Record health data
  Future<void> recordHealthData({
    required DateTime date,
    int? stepsCount,
    double? sleepHours,
    int? heartRate,
    int? activeMinutes,
  }) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await client.from('health_data').upsert({
        'user_id': user.id,
        'date': dateString,
        'steps_count': stepsCount ?? 0,
        'sleep_hours': sleepHours ?? 0,
        'heart_rate': heartRate,
        'active_minutes': activeMinutes ?? 0,
        'sync_status': 'synced',
      });
    } catch (error) {
      throw Exception('Failed to record health data: $error');
    }
  }

  // Record notification event
  Future<void> recordNotificationEvent({
    required String appName,
    required DateTime notificationTime,
    int? responseTimeSeconds,
  }) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await client.from('notification_events').insert({
        'user_id': user.id,
        'app_name': appName,
        'notification_time': notificationTime.toIso8601String(),
        'response_time_seconds': responseTimeSeconds,
        'sync_status': 'synced',
      });
    } catch (error) {
      throw Exception('Failed to record notification event: $error');
    }
  }

  // Get health data for date
  Future<Map<String, dynamic>?> getHealthData({DateTime? date}) async {
    try {
      final client = await _client;
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final targetDate = date ?? DateTime.now();
      final dateString =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('health_data')
          .select()
          .eq('user_id', user.id)
          .eq('date', dateString)
          .single();

      return response;
    } catch (error) {
      // Return null if no health data found for the date
      return null;
    }
  }
}
