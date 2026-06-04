/// Echo — App Constants
///
/// API URLs, app strings, and configuration values.

class AppConstants {
  // API
  static const String apiBaseUrl = 'https://echo-app-h4o1.onrender.com';
  static const String apiBaseUrlLocal = 'http://127.0.0.1:5000'; // Localhost for ADB reverse port forwarding

  // App Info
  static const String appName = 'Echo';
  static const String appTagline = 'Your second memory';
  static const String appVersion = '1.0.0';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String addMemoryRoute = '/add-memory';
  static const String memoryDetailRoute = '/memory-detail';
  static const String profileRoute = '/profile';
}
