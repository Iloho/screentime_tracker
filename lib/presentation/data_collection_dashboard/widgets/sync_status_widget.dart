import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final String lastSyncTime;
  final bool isSyncing;

  const SyncStatusWidget({
    Key? key,
    required this.lastSyncTime,
    this.isSyncing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'cloud_sync',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSyncing
                    ? AppTheme.warningLight.withValues(alpha: 0.1)
                    : AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSyncing
                      ? AppTheme.warningLight.withValues(alpha: 0.3)
                      : AppTheme.successLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  isSyncing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.warningLight,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.successLight,
                          size: 16,
                        ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSyncing ? 'Syncing data...' : 'Data synchronized',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isSyncing
                                        ? AppTheme.warningLight
                                        : AppTheme.successLight,
                                  ),
                        ),
                        if (!isSyncing) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            'Last sync: $lastSyncTime',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isSyncing) ...[
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Data is automatically synced every 15 minutes when connected to WiFi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
