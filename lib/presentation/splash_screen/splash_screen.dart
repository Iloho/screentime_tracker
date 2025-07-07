import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import './widgets/splash_loading_widget.dart';
import './widgets/splash_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    _loadingController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));

    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    // Start loading animation
    _loadingController.repeat();

    try {
      // Check authentication status
      final isAuthenticated = _authService.isAuthenticated();

      // Simulate minimum loading time for UX
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        if (isAuthenticated) {
          // User is logged in, go to dashboard
          Navigator.pushReplacementNamed(context, '/data-collection-dashboard');
        } else {
          // User is not logged in, go to onboarding
          Navigator.pushReplacementNamed(context, '/onboarding-welcome');
        }
      }
    } catch (error) {
      // If there's an error, go to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding-welcome');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              // Logo section
              AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child:
                                SplashLogoWidget(animation: _logoController)));
                  }),

              SizedBox(height: 8.h),

              // App title
              AnimatedBuilder(
                  animation: _logoOpacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Column(children: [
                          Text('ScreenTime Tracker',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold)),
                          SizedBox(height: 1.h),
                          Text('Understand Your Digital Habits',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.8))),
                        ]));
                  }),

              SizedBox(height: 8.h),

              // Loading indicator
              AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return SplashLoadingWidget(
                      hasError: false,
                      isLoading: true,
                      loadingText: 'Loading...',
                    );
                  }),

              SizedBox(height: 3.h),

              // Loading text
              AnimatedBuilder(
                  animation: _logoOpacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                        opacity: _logoOpacityAnimation.value * 0.7,
                        child: Text('Initializing data collection...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.7))));
                  }),
            ]))));
  }
}
