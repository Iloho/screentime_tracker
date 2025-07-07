import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/benefit_card_widget.dart';
import './widgets/onboarding_illustration_widget.dart';

class OnboardingWelcome extends StatefulWidget {
  const OnboardingWelcome({super.key});

  @override
  State<OnboardingWelcome> createState() => _OnboardingWelcomeState();
}

class _OnboardingWelcomeState extends State<OnboardingWelcome> {
  bool _isLearnMoreExpanded = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _benefitCards = [
    {
      "icon": "schedule",
      "title": "Track Screen Time Patterns",
      "description":
          "Discover when and how you use your device throughout the day"
    },
    {
      "icon": "psychology",
      "title": "Discover Usage Triggers",
      "description": "Understand what motivates your digital behavior patterns"
    },
    {
      "icon": "favorite",
      "title": "Build Healthier Habits",
      "description": "Create positive changes based on your personal insights"
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPermissionSetup() {
    Navigator.pushNamed(context, '/permission-setup');
  }

  void _skipOnboarding() {
    Navigator.pushNamed(context, '/data-collection-dashboard');
  }

  void _toggleLearnMore() {
    setState(() {
      _isLearnMoreExpanded = !_isLearnMoreExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildSkipButton(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 4.h),

                    // Illustration
                    OnboardingIllustrationWidget(),

                    SizedBox(height: 6.h),

                    // Main heading
                    _buildMainHeading(),

                    SizedBox(height: 3.h),

                    // Subtext
                    _buildSubtext(),

                    SizedBox(height: 5.h),

                    // Benefit cards
                    _buildBenefitCards(),

                    SizedBox(height: 5.h),

                    // Learn more section
                    _buildLearnMoreSection(),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Bottom section with buttons and pagination
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, right: 4.w),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: _skipOnboarding,
          child: Text(
            'Skip',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainHeading() {
    return Text(
      'Understand Your Digital Habits',
      textAlign: TextAlign.center,
      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSubtext() {
    return Text(
      'Gain personal insights into your screen time patterns and build healthier digital relationships through data-driven understanding.',
      textAlign: TextAlign.center,
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }

  Widget _buildBenefitCards() {
    return Column(
      children: _benefitCards.map((benefit) {
        return Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: BenefitCardWidget(
            icon: benefit["icon"] as String,
            title: benefit["title"] as String,
            description: benefit["description"] as String,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearnMoreSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleLearnMore,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learn More About Our Approach',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomIconWidget(
                    iconName:
                        _isLearnMoreExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isLearnMoreExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLearnMoreItem(
                    'Privacy-First Design',
                    'Your data is encrypted and anonymized. We collect insights, not personal information.',
                  ),
                  SizedBox(height: 2.h),
                  _buildLearnMoreItem(
                    'Scientific Methodology',
                    'Our algorithms are based on behavioral psychology research and machine learning best practices.',
                  ),
                  SizedBox(height: 2.h),
                  _buildLearnMoreItem(
                    'Your Control',
                    'You can pause data collection, delete your data, or opt out at any time.',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearnMoreItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pagination dots
          _buildPaginationDots(),

          SizedBox(height: 4.h),

          // Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToPermissionSetup,
              style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                minimumSize:
                    WidgetStateProperty.all(Size(double.infinity, 6.h)),
              ),
              child: Text(
                'Get Started',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Learn More button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _toggleLearnMore,
              style: AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
                minimumSize:
                    WidgetStateProperty.all(Size(double.infinity, 6.h)),
              ),
              child: Text(
                _isLearnMoreExpanded ? 'Show Less' : 'Learn More',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: index == 0 ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: index == 0
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
