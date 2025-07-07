import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String iconName;
  final String trend;
  final String trendValue;
  final VoidCallback? onTap;

  const SummaryCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.iconName,
    required this.trend,
    required this.trendValue,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositiveTrend = trend == 'up';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconWidget(
                    iconName: iconName,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPositiveTrend
                              ? AppTheme.successLight
                              : AppTheme.errorLight)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: isPositiveTrend
                              ? 'arrow_upward'
                              : 'arrow_downward',
                          color: isPositiveTrend
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trendValue,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isPositiveTrend
                                        ? AppTheme.successLight
                                        : AppTheme.errorLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
