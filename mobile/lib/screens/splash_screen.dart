/// Echo — Splash Screen
///
/// Animated logo with auto-navigation based on auth state.

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Navigate after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;

    final authService = AuthService();
    final route = authService.isLoggedIn
        ? AppConstants.homeRoute
        : AppConstants.loginRoute;

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: EchoColors.background,
        ),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      EchoColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -30,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      EchoColors.secondary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Logo and text
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: EchoColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: EchoColors.primary.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App name
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            EchoColors.primaryGradient.createShader(bounds),
                        child: Text(
                          'Echo',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: EchoColors.textSecondary,
                              letterSpacing: 2,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
