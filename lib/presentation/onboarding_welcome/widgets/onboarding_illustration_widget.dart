import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingIllustrationWidget extends StatelessWidget {
  const OnboardingIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 35.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient circle
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Main smartphone illustration
          Container(
            width: 40.w,
            height: 25.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Phone header
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 8.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Phone screen content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      children: [
                        // Mock chart visualization
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Chart bars
                                Positioned(
                                  bottom: 2.w,
                                  left: 2.w,
                                  right: 2.w,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildChartBar(4.h),
                                      _buildChartBar(6.h),
                                      _buildChartBar(3.h),
                                      _buildChartBar(7.h),
                                      _buildChartBar(5.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.w),

                        // Mock app usage indicators
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildUsageIndicator(
                                  'Social Media', '2h 45m', 0.7),
                              SizedBox(height: 1.w),
                              _buildUsageIndicator(
                                  'Productivity', '1h 20m', 0.4),
                              SizedBox(height: 1.w),
                              _buildUsageIndicator('Entertainment', '45m', 0.3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating data points
          _buildFloatingDataPoint(
            top: 8.h,
            left: 15.w,
            icon: 'schedule',
            value: '6h 23m',
          ),

          _buildFloatingDataPoint(
            top: 12.h,
            right: 10.w,
            icon: 'notifications',
            value: '47',
          ),

          _buildFloatingDataPoint(
            bottom: 8.h,
            left: 10.w,
            icon: 'trending_up',
            value: '+12%',
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height) {
    return Container(
      width: 1.5.w,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildUsageIndicator(String label, String time, double progress) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          time,
          style: TextStyle(
            fontSize: 7.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingDataPoint({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String icon,
    required String value,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
