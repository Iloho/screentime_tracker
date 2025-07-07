import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../services/screen_time_service.dart';
import '../../services/data_collection_service.dart';
import './widgets/activity_timeline_widget.dart';
import './widgets/status_card_widget.dart';
import './widgets/summary_card_widget.dart';
import './widgets/sync_status_widget.dart';

class DataCollectionDashboard extends StatefulWidget {
  const DataCollectionDashboard({Key? key}) : super(key: key);

  @override
  State<DataCollectionDashboard> createState() =>
      _DataCollectionDashboardState();
}

class _DataCollectionDashboardState extends State<DataCollectionDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final AuthService _authService = AuthService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final DataCollectionService _dataCollectionService = DataCollectionService();

  bool _isCollectionActive = true;
  bool _isRefreshing = false;
  bool _isSyncing = false;
  bool _isLoading = true;

  // Real data from Supabase
  Map<String, dynamic> _dashboardData = {
    "totalDataPoints": 0,
    "screenTimeToday": 0.0,
    "appSessions": 0,
    "locationPoints": 0,
    "healthSteps": 0,
    "lastSyncTime": "Never",
    "recentActivities": <Map<String, dynamic>>[],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dataCollectionService.stopCollection();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated()) {
        Navigator.pushReplacementNamed(context, '/sign-in');
        return;
      }

      await _loadDashboardData();

      // Start data collection if not already running
      if (!_dataCollectionService.isCollecting) {
        await _dataCollectionService.startCollection();
      }

      setState(() {
        _isCollectionActive = _dataCollectionService.isCollecting;
        _isLoading = false;
      });
    } catch (error) {
      print('Error initializing dashboard: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get today's stats
      final dailyStats = await _screenTimeService.getDailyStats();

      // Get recent screen sessions
      final recentSessions = await _screenTimeService.getTodayScreenSessions();

      // Get health data
      final healthData = await _screenTimeService.getHealthData();

      // Get collection stats
      final collectionStats = await _screenTimeService.getCollectionStats();

      // Transform recent sessions to activities format
      final recentActivities = recentSessions.take(5).map((session) {
        final startTime = DateTime.parse(session['session_start']);
        final timeFormat =
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';

        return {
          "appName": session['app_name'] ?? 'Unknown',
          "duration": "${session['duration_minutes'] ?? 0} min",
          "timestamp": timeFormat,
          "icon": _getIconForCategory(session['app_category'] ?? 'other'),
          "category": _capitalizeCategory(session['app_category'] ?? 'Other'),
        };
      }).toList();

      setState(() {
        _dashboardData = {
          "totalDataPoints":
              recentSessions.length + (healthData != null ? 1 : 0),
          "screenTimeToday":
              (dailyStats['total_screen_time_minutes'] ?? 0) / 60.0,
          "appSessions": dailyStats['total_sessions'] ?? 0,
          "locationPoints": collectionStats?['location_points'] ?? 0,
          "healthSteps": healthData?['steps_count'] ?? 0,
          "lastSyncTime": collectionStats?['last_sync_at'] != null
              ? _formatLastSync(collectionStats!['last_sync_at'])
              : "Never",
          "recentActivities": recentActivities,
        };
      });
    } catch (error) {
      print('Error loading dashboard data: $error');
      // Keep existing data or show empty state
    }
  }

  String _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return 'people';
      case 'productivity':
        return 'work';
      case 'entertainment':
        return 'movie';
      case 'communication':
        return 'chat';
      case 'browser':
        return 'web';
      case 'music':
        return 'music_note';
      case 'games':
        return 'sports_esports';
      default:
        return 'apps';
    }
  }

  String _capitalizeCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }

  String _formatLastSync(String lastSyncTime) {
    try {
      final syncTime = DateTime.parse(lastSyncTime);
      final now = DateTime.now();
      final difference = now.difference(syncTime);

      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else {
        return "${difference.inDays} days ago";
      }
    } catch (error) {
      return "Unknown";
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadDashboardData();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _dataCollectionService.syncData();
      await _loadDashboardData();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _toggleCollection() async {
    try {
      if (_isCollectionActive) {
        _dataCollectionService.stopCollection();
      } else {
        await _dataCollectionService.startCollection();
      }

      setState(() {
        _isCollectionActive = _dataCollectionService.isCollecting;
      });

      // Update collection status in database
      await _screenTimeService.updateCollectionStats(
        date: DateTime.now(),
        isCollectionActive: _isCollectionActive,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle collection: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showCardDetails(String cardType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$cardType Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Detailed breakdown for $cardType would be displayed here with charts and historical data.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ScreenTime Tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
            icon: CustomIconWidget(
              iconName: 'logout',
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Insights'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildInsightsTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _isSyncing ? null : _handleSync,
              icon: _isSyncing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'sync',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
              label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
              backgroundColor: _isSyncing
                  ? Theme.of(context).colorScheme.outline
                  : Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            StatusCardWidget(
              isActive: _isCollectionActive,
              totalDataPoints: _dashboardData["totalDataPoints"] as int,
              onToggle: _toggleCollection,
              isRefreshing: _isRefreshing,
            ),

            SizedBox(height: 3.h),

            // Summary Cards Grid
            Text(
              'Today\'s Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            SizedBox(height: 2.h),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
              children: [
                SummaryCardWidget(
                  title: 'Screen Time',
                  value:
                      '${(_dashboardData["screenTimeToday"] as double).toStringAsFixed(1)}h',
                  iconName: 'phone_android',
                  trend: 'up',
                  trendValue: '+12%',
                  onTap: () => _showCardDetails('Screen Time'),
                ),
                SummaryCardWidget(
                  title: 'App Sessions',
                  value: '${_dashboardData["appSessions"]}',
                  iconName: 'apps',
                  trend: 'down',
                  trendValue: '-5%',
                  onTap: () => _showCardDetails('App Sessions'),
                ),
                SummaryCardWidget(
                  title: 'Location Points',
                  value: '${_dashboardData["locationPoints"]}',
                  iconName: 'location_on',
                  trend: 'up',
                  trendValue: '+8%',
                  onTap: () => _showCardDetails('Location Points'),
                ),
                SummaryCardWidget(
                  title: 'Health Steps',
                  value: '${_dashboardData["healthSteps"]}',
                  iconName: 'directions_walk',
                  trend: 'up',
                  trendValue: '+15%',
                  onTap: () => _showCardDetails('Health Steps'),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Recent Activity Timeline
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            SizedBox(height: 2.h),

            ActivityTimelineWidget(
              activities: (_dashboardData["recentActivities"] as List)
                  .cast<Map<String, dynamic>>(),
            ),

            SizedBox(height: 3.h),

            // Sync Status
            SyncStatusWidget(
              lastSyncTime: _dashboardData["lastSyncTime"] as String,
              isSyncing: _isSyncing,
            ),

            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'insights',
            color: Theme.of(context).colorScheme.outline,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Insights Coming Soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'Advanced analytics and patterns will be available here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Collection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'pause_circle',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('Pause Collection'),
                  subtitle: const Text('Temporarily stop data collection'),
                  trailing: Switch(
                    value: !_isCollectionActive,
                    onChanged: (value) => _toggleCollection(),
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'sync',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('Sync Now'),
                  subtitle: const Text('Manually sync data to cloud'),
                  onTap: _handleSync,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'person',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('Profile'),
                  subtitle: const Text('Manage your account settings'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  onTap: () {
                    // Navigate to profile
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'logout',
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  title: const Text('Sign Out'),
                  subtitle: const Text('Sign out of your account'),
                  onTap: () async {
                    await _authService.signOut();
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
