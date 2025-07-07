import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';

import './screen_time_service.dart';

class DataCollectionService {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  Timer? _collectionTimer;
  bool _isCollecting = false;

  static final DataCollectionService _instance =
      DataCollectionService._internal();
  factory DataCollectionService() => _instance;
  DataCollectionService._internal();

  // Start data collection
  Future<void> startCollection() async {
    if (_isCollecting) return;

    try {
      _isCollecting = true;

      // Start periodic collection every 5 minutes
      _collectionTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _collectAllData(),
      );

      // Initial collection
      await _collectAllData();
    } catch (error) {
      _isCollecting = false;
      throw Exception('Failed to start data collection: $error');
    }
  }

  // Stop data collection
  void stopCollection() {
    _collectionTimer?.cancel();
    _collectionTimer = null;
    _isCollecting = false;
  }

  bool get isCollecting => _isCollecting;

  // Collect all available data
  Future<void> _collectAllData() async {
    try {
      await Future.wait([
        _collectUsageStats(),
        _collectLocationData(),
        _collectHealthData(),
        _collectNotificationData(),
      ]);
    } catch (error) {
      print('Error during data collection: $error');
    }
  }

  // Collect app usage statistics
  Future<void> _collectUsageStats() async {
    try {
      if (Platform.isAndroid) {
        // Check if usage stats permission is granted
        final hasPermission = await UsageStats.checkUsagePermission();
        if (hasPermission != true) return;

        final endTime = DateTime.now();
        final startTime = endTime.subtract(const Duration(hours: 1));

        final usageStats = await UsageStats.queryUsageStats(
          startTime,
          endTime,
        );

        for (final stat in usageStats) {
          if (stat.totalTimeInForeground != null &&
              (stat.totalTimeInForeground as String).isNotEmpty) {
            final durationMinutes =
                (int.parse(stat.totalTimeInForeground as String) / (1000 * 60))
                    .round();

            if (durationMinutes > 0) {
              await _screenTimeService.recordScreenSession(
                appName: stat.packageName ?? 'Unknown',
                appPackage: stat.packageName,
                appCategory: _getAppCategory(stat.packageName ?? ''),
                sessionStart: startTime,
                sessionEnd: endTime,
                durationMinutes: durationMinutes,
              );
            }
          }
        }
      }
    } catch (error) {
      print('Error collecting usage stats: $error');
    }
  }

  // Collect location data
  Future<void> _collectLocationData() async {
    try {
      final permission = await Permission.location.status;
      if (!permission.isGranted) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Store location with recent sessions (privacy-conscious)
      // This is a simplified implementation
      final recentSessions = await _screenTimeService.getTodayScreenSessions();
      if (recentSessions.isNotEmpty) {
        final lastSession = recentSessions.first;
        // Update last session with location if it doesn't have one
        if (lastSession['location_lat'] == null) {
          // In a real implementation, you'd update the session
          // For this example, we'll record a new session with location
        }
      }
    } catch (error) {
      print('Error collecting location data: $error');
    }
  }

  // Collect health data
  Future<void> _collectHealthData() async {
    try {
      final health = Health();

      // Request permissions for health data
      final types = [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      final hasPermissions = await health.requestAuthorization(types);
      if (!hasPermissions) return;

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Get health data for the last 24 hours
      final healthData = await health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );

      // Process and aggregate health data
      int steps = 0;
      double sleepHours = 0;
      int heartRate = 0;
      int activeMinutes = 0;

      for (final data in healthData) {
        switch (data.type) {
          case HealthDataType.STEPS:
            steps += (data.value as num).toInt();
            break;
          case HealthDataType.SLEEP_IN_BED:
            sleepHours +=
                (data.value as num).toDouble() / 60; // Convert to hours
            break;
          case HealthDataType.HEART_RATE:
            heartRate = (data.value as num).toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            activeMinutes += (data.value as num).toInt() ~/ 5; // Estimate
            break;
          default:
            break;
        }
      }

      await _screenTimeService.recordHealthData(
        date: DateTime.now(),
        stepsCount: steps,
        sleepHours: sleepHours,
        heartRate: heartRate > 0 ? heartRate : null,
        activeMinutes: activeMinutes,
      );
    } catch (error) {
      print('Error collecting health data: $error');
    }
  }

  // Collect notification data (simplified)
  Future<void> _collectNotificationData() async {
    try {
      final permission = await Permission.notification.status;
      if (!permission.isGranted) return;

      // This is a simplified implementation
      // In a real app, you'd need to listen to notification events
      // For this example, we'll simulate some notification data

      final now = DateTime.now();
      final apps = ['Instagram', 'WhatsApp', 'Gmail', 'Spotify'];

      for (final app in apps) {
        if (DateTime.now().millisecond % 4 == 0) {
          // Random simulation
          await _screenTimeService.recordNotificationEvent(
            appName: app,
            notificationTime: now
                .subtract(Duration(minutes: DateTime.now().millisecond % 60)),
            responseTimeSeconds: DateTime.now().millisecond % 30,
          );
        }
      }
    } catch (error) {
      print('Error collecting notification data: $error');
    }
  }

  // Get app category based on package name
  String _getAppCategory(String packageName) {
    final socialApps = [
      'instagram',
      'facebook',
      'twitter',
      'snapchat',
      'tiktok'
    ];
    final productivityApps = ['gmail', 'office', 'docs', 'sheets', 'slack'];
    final entertainmentApps = ['netflix', 'youtube', 'spotify', 'music'];
    final communicationApps = ['whatsapp', 'telegram', 'messenger', 'skype'];
    final browserApps = ['chrome', 'firefox', 'safari', 'browser'];
    final gamesApps = ['game', 'play', 'puzzle', 'casino'];

    final lowerPackage = packageName.toLowerCase();

    if (socialApps.any((app) => lowerPackage.contains(app))) {
      return 'social';
    } else if (productivityApps.any((app) => lowerPackage.contains(app))) {
      return 'productivity';
    } else if (entertainmentApps.any((app) => lowerPackage.contains(app))) {
      return 'entertainment';
    } else if (communicationApps.any((app) => lowerPackage.contains(app))) {
      return 'communication';
    } else if (browserApps.any((app) => lowerPackage.contains(app))) {
      return 'browser';
    } else if (gamesApps.any((app) => lowerPackage.contains(app))) {
      return 'games';
    } else {
      return 'other';
    }
  }

  // Request all necessary permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final permissions = <String, bool>{};

    try {
      // Usage stats permission (Android specific)
      if (Platform.isAndroid) {
        permissions['usage_stats'] =
            await UsageStats.checkUsagePermission() ?? false;
        if (permissions['usage_stats'] == false) {
          await UsageStats.grantUsagePermission();
          permissions['usage_stats'] =
              await UsageStats.checkUsagePermission() ?? false;
        }
      } else {
        permissions['usage_stats'] = false; // iOS doesn't have this
      }

      // Location permission
      final locationStatus = await Permission.location.request();
      permissions['location'] = locationStatus.isGranted;

      // Health permission
      final health = Health();
      final healthTypes = [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.HEART_RATE,
      ];
      permissions['health'] = await health.requestAuthorization(healthTypes);

      // Notification permission
      final notificationStatus = await Permission.notification.request();
      permissions['notifications'] = notificationStatus.isGranted;
    } catch (error) {
      print('Error requesting permissions: $error');
    }

    return permissions;
  }

  // Get permission status
  Future<Map<String, bool>> getPermissionStatus() async {
    final permissions = <String, bool>{};

    try {
      // Usage stats
      if (Platform.isAndroid) {
        permissions['usage_stats'] =
            await UsageStats.checkUsagePermission() ?? false;
      } else {
        permissions['usage_stats'] = false;
      }

      // Location
      final locationStatus = await Permission.location.status;
      permissions['location'] = locationStatus.isGranted;

      // Health (simplified check)
      permissions['health'] = true; // Assume granted for simplicity

      // Notifications
      final notificationStatus = await Permission.notification.status;
      permissions['notifications'] = notificationStatus.isGranted;
    } catch (error) {
      print('Error getting permission status: $error');
    }

    return permissions;
  }

  // Sync data with backend
  Future<void> syncData() async {
    try {
      // Update collection stats
      final now = DateTime.now();
      final todayStats = await _screenTimeService.getDailyStats(date: now);

      await _screenTimeService.updateCollectionStats(
        date: now,
        totalScreenTimeMinutes: todayStats['total_screen_time_minutes'] ?? 0,
        totalSessions: todayStats['total_sessions'] ?? 0,
        totalNotifications: todayStats['total_notifications'] ?? 0,
        locationPoints: 50, // Simplified
        isCollectionActive: _isCollecting,
      );
    } catch (error) {
      throw Exception('Failed to sync data: $error');
    }
  }
}