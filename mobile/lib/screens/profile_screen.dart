/// Echo — Profile Screen
///
/// Displays user info, memory statistics, and sign-out option.

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/memory_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _memoryService = MemoryService();
  bool _isLoading = false;
  Map<String, int> _stats = {'total': 0, 'completed': 0, 'pending': 0};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _memoryService.getStats();
      setState(() => _stats = stats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stats: $e'),
            backgroundColor: EchoColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: EchoColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.loginRoute,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final displayName = user?.displayName ?? 'Echo User';
    final email = user?.email ?? 'user@echo-app.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Profile Icon / Avatar
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: EchoColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: EchoColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Info
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EchoColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 36),

            // Statistics Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: EchoColors.primary,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: EchoColors.textSecondary),
                    onPressed: _loadStats,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Stat Cards Grid / Row
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context,
                    label: 'Total',
                    value: _stats['total'].toString(),
                    color: EchoColors.primary,
                    icon: Icons.all_inbox_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    context,
                    label: 'Pending',
                    value: _stats['pending'].toString(),
                    color: EchoColors.warning,
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    context,
                    label: 'Completed',
                    value: _stats['completed'].toString(),
                    color: EchoColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Action List
            Container(
              decoration: EchoDecorations.glassCard(opacity: 0.05),
              child: Column(
                children: [
                  _profileActionTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About Echo',
                    subtitle: 'Version ${AppConstants.appVersion}',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationIcon: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: EchoColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Echo is an AI-powered memory assistant that captures your natural thoughts and reminds you at the right time and place.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: EchoColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EchoColors.error.withValues(alpha: 0.08),
                    foregroundColor: EchoColors.error,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EchoDecorations.glassCard(opacity: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: EchoColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EchoColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _profileActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: EchoColors.primary.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: EchoColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: EchoColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: EchoColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
