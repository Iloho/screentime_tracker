import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> permission;
  final VoidCallback onTap;
  final VoidCallback onGrantPermission;

  const PermissionCardWidget({
    Key? key,
    required this.permission,
    required this.onTap,
    required this.onGrantPermission,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'granted':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'denied':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'granted':
        return 'Granted';
      case 'denied':
        return 'Denied';
      default:
        return 'Pending';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'granted':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = permission["status"] ?? "pending";
    final bool isRequired = permission["isRequired"] ?? false;

    return Card(
      elevation: 2,
      shadowColor: AppTheme.lightTheme.colorScheme.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Permission icon
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: permission["icon"] ?? "security",
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Permission name and required badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                permission["name"] ?? "",
                                style:
                                    AppTheme.lightTheme.textTheme.titleMedium,
                              ),
                            ),
                            if (isRequired)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.error
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Required',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getStatusText(status),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                permission["description"] ?? "",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),

              SizedBox(height: 2.h),

              // Action buttons
              Row(
                children: [
                  // Info button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      label: Text('Learn More'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Action button
                  Expanded(
                    child: status == 'granted'
                        ? ElevatedButton.icon(
                            onPressed: onTap,
                            icon: CustomIconWidget(
                              iconName: 'settings',
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text('Configure'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                          )
                        : status == 'denied'
                            ? ElevatedButton.icon(
                                onPressed: onGrantPermission,
                                icon: CustomIconWidget(
                                  iconName: 'settings',
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: Text('Open Settings'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.error,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: onGrantPermission,
                                icon: CustomIconWidget(
                                  iconName: 'check',
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: Text('Grant'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                ),
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
