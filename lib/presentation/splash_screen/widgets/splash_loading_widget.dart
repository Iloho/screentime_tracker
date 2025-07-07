import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String loadingText;
  final VoidCallback? onRetry;

  const SplashLoadingWidget({
    Key? key,
    required this.isLoading,
    required this.hasError,
    required this.loadingText,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoadingIndicator(),
        SizedBox(height: 2.h),
        _buildLoadingText(),
        if (hasError && onRetry != null) ...[
          SizedBox(height: 2.h),
          _buildRetryButton(),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    if (hasError) {
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.errorLight.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.errorLight.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.errorLight,
            size: 6.w,
          ),
        ),
      );
    }

    if (!isLoading) {
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.successLight.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.successLight.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.successLight,
            size: 6.w,
          ),
        ),
      );
    }

    return SizedBox(
      width: 12.w,
      height: 12.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.9),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildLoadingText() {
    return Container(
      constraints: BoxConstraints(maxWidth: 70.w),
      child: Text(
        loadingText,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.lightTheme.primaryColor,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.primaryColor,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              'Retry',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
