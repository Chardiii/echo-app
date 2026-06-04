/// Echo — Home Screen
///
/// Memory list with FAB, pull-to-refresh, and empty state.

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/memory_service.dart';
import '../widgets/memory_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _memoryService = MemoryService();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                EchoColors.primaryGradient
                                    .createShader(bounds),
                            child: Text(
                              'Echo',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your memories',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    // Profile button
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppConstants.profileRoute,
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: EchoDecorations.glassCard(
                          borderRadius: 14,
                          opacity: 0.12,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: EchoColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Memory list
              Expanded(
                child: StreamBuilder<List<Memory>>(
                  stream: _memoryService.getMemories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: EchoColors.primary,
                        ),
                      );
                    }

                    final memories = snapshot.data ?? [];

                    if (memories.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: EchoColors.primary,
                      backgroundColor: EchoColors.surface,
                      onRefresh: () async {
                        // Stream auto-refreshes, but add a small delay
                        // for UX feedback
                        await Future.delayed(
                          const Duration(milliseconds: 500),
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 300 + (index * 80),
                            ),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: MemoryCard(
                              memory: memory,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppConstants.memoryDetailRoute,
                                arguments: memory,
                              ),
                              onToggle: (completed) {
                                _memoryService.toggleCompleted(
                                  memory.id,
                                  completed ?? false,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: EchoColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: EchoColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppConstants.addMemoryRoute),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EchoColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 44,
                color: EchoColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No memories yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the + button to capture your\nfirst thought',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
