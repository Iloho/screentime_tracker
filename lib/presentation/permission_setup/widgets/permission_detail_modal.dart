import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionDetailModal extends StatelessWidget {
  final Map<String, dynamic> permission;
  final VoidCallback onGrantPermission;

  const PermissionDetailModal({
    Key? key,
    required this.permission,
    required this.onGrantPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: permission["icon"] ?? "security",
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permission["name"] ?? "",
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                      ),
                      if (permission["isRequired"] == true)
                        Container(
                          margin: EdgeInsets.only(top: 0.5.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Required Permission',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Why We Need This Permission',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    permission["detailedDescription"] ?? "",
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),

                  SizedBox(height: 3.h),

                  // Data collected section
                  Text(
                    'Data We Collect',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),

                  ...(permission["dataCollected"] as List? ?? [])
                      .map<Widget>((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 0.5.h),
                            width: 1.w,
                            height: 1.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              item as String,
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 3.h),

                  // Privacy protections section
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
                              iconName: 'shield',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Privacy Protections',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        ...(permission["privacyProtections"] as List? ?? [])
                            .map<Widget>((protection) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    protection as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Bottom actions
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
                    onPressed: onGrantPermission,
                    child: Text('Grant ${permission["name"]}'),
                  ),
                ),
                SizedBox(height: 1.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Maybe Later'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
