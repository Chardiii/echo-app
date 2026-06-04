/// Echo — App Entry Point
///
/// Initializes Firebase, configures notification services,
/// maps routes, and applies the custom theme.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_memory_screen.dart';
import 'screens/memory_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'services/notification_service.dart';
import 'services/memory_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // Initialize Notifications
  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (e) {
    debugPrint('Notification initialization warning: $e');
  }

  runApp(const EchoApp());
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: EchoTheme.darkTheme,
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        AppConstants.addMemoryRoute: (context) => const AddMemoryScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppConstants.memoryDetailRoute) {
          final args = settings.arguments;
          if (args is Memory) {
            return MaterialPageRoute(
              builder: (context) => MemoryDetailScreen(memory: args),
            );
          }
        }
        return null;
      },
    );
  }
}
