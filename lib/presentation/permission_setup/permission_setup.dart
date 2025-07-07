import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/data_collection_service.dart';
import './widgets/permission_card_widget.dart';
import './widgets/permission_detail_modal.dart';
import './widgets/progress_header_widget.dart';

class PermissionSetup extends StatefulWidget {
  const PermissionSetup({Key? key}) : super(key: key);

  @override
  State<PermissionSetup> createState() => _PermissionSetupState();
}

class _PermissionSetupState extends State<PermissionSetup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final DataCollectionService _dataCollectionService = DataCollectionService();
  Map<String, bool> _permissionStatus = {};
  bool _isLoading = true;

  // Permission configuration data
  final List<Map<String, dynamic>> permissionData = [
    {
      "id": 1,
      "key": "usage_stats",
      "name": "Screen Time Access",
      "icon": "screen_lock_portrait",
      "status": "pending",
      "description": "Monitor app usage patterns and screen time data",
      "detailedDescription":
          "We collect app usage statistics including session duration, frequency of use, and time spent in each application. This data helps us understand your digital habits and identify patterns that may indicate screen time addiction. All data is anonymized and encrypted before storage.",
      "dataCollected": [
        "App session duration",
        "Frequency of app launches",
        "Time of day usage patterns",
        "App categories and types"
      ],
      "privacyProtections": [
        "Data is anonymized with unique IDs",
        "No personal information is stored",
        "Encrypted transmission and storage",
        "You can delete your data anytime"
      ],
      "isRequired": true
    },
    {
      "id": 2,
      "key": "location",
      "name": "Location Services",
      "icon": "location_on",
      "status": "pending",
      "description": "Understand usage patterns based on location context",
      "detailedDescription":
          "Location data helps us understand how your environment affects your screen time habits. We collect general location information to identify patterns like increased usage at home vs. work, without storing specific addresses.",
      "dataCollected": [
        "General location coordinates",
        "Location-based usage patterns",
        "Time spent in different locations",
        "Movement patterns during high usage"
      ],
      "privacyProtections": [
        "Only general location areas stored",
        "No specific addresses recorded",
        "Location data is aggregated",
        "GPS precision reduced for privacy"
      ],
      "isRequired": false
    },
    {
      "id": 3,
      "key": "health",
      "name": "Health Data",
      "icon": "favorite",
      "status": "pending",
      "description": "Correlate screen time with health metrics",
      "detailedDescription":
          "Health data integration allows us to understand how screen time affects your physical well-being. We access basic health metrics to identify correlations between device usage and health patterns.",
      "dataCollected": [
        "Step count and activity levels",
        "Sleep duration and quality",
        "Heart rate during usage",
        "Physical activity patterns"
      ],
      "privacyProtections": [
        "Health data never leaves your device",
        "Only aggregated patterns analyzed",
        "No medical information stored",
        "Full control over data sharing"
      ],
      "isRequired": false
    },
    {
      "id": 4,
      "key": "notifications",
      "name": "Notifications",
      "icon": "notifications",
      "status": "pending",
      "description": "Track notification frequency and interruption patterns",
      "detailedDescription":
          "Notification data helps us understand how interruptions affect your screen time behavior. We monitor notification frequency and timing to identify patterns that may contribute to excessive device usage.",
      "dataCollected": [
        "Notification frequency per app",
        "Time of day notification patterns",
        "Response time to notifications",
        "Interruption impact on usage"
      ],
      "privacyProtections": [
        "No notification content accessed",
        "Only frequency and timing data",
        "App-level aggregation only",
        "No personal message content"
      ],
      "isRequired": false
    }
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadPermissionStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissionStatus() async {
    try {
      final status = await _dataCollectionService.getPermissionStatus();
      setState(() {
        _permissionStatus = status;
        _isLoading = false;

        // Update permission data with real status
        for (var permission in permissionData) {
          final key = permission['key'] as String;
          if (_permissionStatus.containsKey(key)) {
            permission['status'] =
                _permissionStatus[key]! ? 'granted' : 'pending';
          }
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading permission status: $error');
    }
  }

  void _updatePermissionStatus(int permissionId, String newStatus) {
    setState(() {
      final index = permissionData.indexWhere((p) => p["id"] == permissionId);
      if (index != -1) {
        permissionData[index]["status"] = newStatus;
      }
    });
  }

  void _showPermissionDetail(Map<String, dynamic> permission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PermissionDetailModal(
        permission: permission,
        onGrantPermission: () => _handlePermissionRequest(permission),
      ),
    );
  }

  Future<void> _handlePermissionRequest(Map<String, dynamic> permission) async {
    try {
      // Request all permissions through the service
      final permissions = await _dataCollectionService.requestAllPermissions();

      // Update status based on actual results
      await _loadPermissionStatus();

      Navigator.pop(context);

      // Show feedback
      final permissionKey = permission["key"] as String;
      final isGranted = permissions[permissionKey] ?? false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isGranted
              ? '${permission["name"]} permission granted!'
              : '${permission["name"]} permission denied'),
          backgroundColor: isGranted
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting permission: ${error.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int get _grantedPermissionsCount {
    return permissionData.where((p) => p["status"] == "granted").length;
  }

  int get _requiredPermissionsCount {
    return permissionData.where((p) => p["isRequired"] == true).length;
  }

  bool get _canContinue {
    final requiredGranted = permissionData
        .where((p) => p["isRequired"] == true && p["status"] == "granted")
        .length;
    return requiredGranted >= _requiredPermissionsCount;
  }

  void _handleContinue() {
    if (_canContinue) {
      Navigator.pushNamed(context, '/data-collection-dashboard');
    }
  }

  void _handleSkip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Limited Functionality',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Skipping permissions will limit the app\'s ability to collect comprehensive data for analysis. You can grant permissions later in settings.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/data-collection-dashboard');
            },
            child: Text('Continue Anyway'),
          ),
        ],
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
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Progress Header
              ProgressHeaderWidget(
                currentStep: 2,
                totalSteps: 4,
                title: 'Permission Setup',
                subtitle: 'Grant permissions for comprehensive data collection',
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // Introduction Text
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'security',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Privacy First Approach',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'We collect data to help you understand your screen time patterns. All data is anonymized, encrypted, and you maintain full control.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Permission Cards
                      Text(
                        'Required Permissions',
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 2.h),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: permissionData.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          final permission = permissionData[index];
                          return PermissionCardWidget(
                            permission: permission,
                            onTap: () => _showPermissionDetail(permission),
                            onGrantPermission: () =>
                                _handlePermissionRequest(permission),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Progress Summary
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style:
                                      AppTheme.lightTheme.textTheme.titleMedium,
                                ),
                                Text(
                                  '$_grantedPermissionsCount/${permissionData.length} granted',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            LinearProgressIndicator(
                              value: _grantedPermissionsCount /
                                  permissionData.length,
                              backgroundColor: AppTheme
                                  .lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _handleContinue : null,
                        child: Text('Continue'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextButton(
                      onPressed: _handleSkip,
                      child: Text('Skip for Now'),
                    ),
                    if (!_canContinue) ...[
                      SizedBox(height: 1.h),
                      Text(
                        'Grant required permissions to continue',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
