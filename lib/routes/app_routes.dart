import 'package:flutter/material.dart';

import '../presentation/auth/signin_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/data_collection_dashboard/data_collection_dashboard.dart';
import '../presentation/onboarding_welcome/onboarding_welcome.dart';
import '../presentation/permission_setup/permission_setup.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingWelcome = '/onboarding-welcome';
  static const String dataCollectionDashboard = '/data-collection-dashboard';
  static const String permissionSetup = '/permission-setup';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingWelcome: (context) => const OnboardingWelcome(),
    dataCollectionDashboard: (context) => const DataCollectionDashboard(),
    permissionSetup: (context) => const PermissionSetup(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    // TODO: Add your other routes here
  };
}
