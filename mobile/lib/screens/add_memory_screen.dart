/// Echo — Add Memory Screen
///
/// Natural language input with AI-parsed preview before saving.

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/memory_service.dart';
import '../services/notification_service.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _memoryService = MemoryService();
  final _notificationService = NotificationService();

  bool _isParsing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _parsedResult;

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
    _textController.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
      _parsedResult = null;
    });

    try {
      final result = await _memoryService.parseMemory(text);
      setState(() => _parsedResult = result);
    } on Exception catch (e) {
      // If API fails, create a basic parse result
      setState(() {
        _parsedResult = {
          'task': text[0].toUpperCase() + text.substring(1),
          'date': null,
          'trigger': 'none',
        };
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI parsing unavailable: ${e.toString().replaceFirst("Exception: ", "")}. Using text as-is.',
            ),
            backgroundColor: EchoColors.warning,
          ),
        );
      }
    } finally {
      setState(() => _isParsing = false);
    }
  }

  Future<void> _saveMemory() async {
    if (_parsedResult == null) return;

    setState(() => _isSaving = true);

    try {
      await _memoryService.createMemory(
        originalText: _textController.text.trim(),
        task: _parsedResult!['task'],
        reminderDate: _parsedResult!['date'],
        reminderType: _parsedResult!['trigger'] ?? 'none',
      );

      // Schedule notification if there's a date
      if (_parsedResult!['date'] != null) {
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Echo Reminder',
          body: _parsedResult!['task'],
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory saved! ✨'),
            backgroundColor: EchoColors.success,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: EchoColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Memory'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input label
              Text(
                'What do you want to remember?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Type naturally, like talking to a friend',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              // Text input
              Container(
                decoration: EchoDecorations.glassCard(opacity: 0.06),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                  cursorColor: EchoColors.primary,
                  decoration: InputDecoration(
                    hintText:
                        'e.g., "Remind me to buy coffee tomorrow at 9 AM"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  onChanged: (_) {
                    // Reset parsed result when text changes
                    if (_parsedResult != null) {
                      setState(() => _parsedResult = null);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Parse button
              if (_parsedResult == null)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: EchoDecorations.gradientButton(),
                    child: ElevatedButton.icon(
                      onPressed: _isParsing ? null : _parseText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isParsing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 20),
                      label: Text(
                        _isParsing ? 'Analyzing...' : 'Analyze with AI',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // Parsed result preview
              if (_parsedResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: EchoDecorations.gradientCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  EchoColors.primary.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: EchoColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'AI Preview',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: EchoColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      _previewRow(
                        context,
                        Icons.task_alt,
                        'Task',
                        _parsedResult!['task'] ?? 'Unknown',
                      ),
                      const SizedBox(height: 12),
                      _previewRow(
                        context,
                        Icons.schedule,
                        'Date',
                        _parsedResult!['date'] ?? 'No date set',
                      ),
                      const SizedBox(height: 12),
                      _previewRow(
                        context,
                        Icons.notifications_outlined,
                        'Type',
                        _parsedResult!['trigger'] ?? 'none',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: EchoDecorations.gradientButton(),
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveMemory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 20),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save Memory',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Re-analyze button
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _parsedResult = null);
                    },
                    child: const Text('Edit & re-analyze'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: EchoColors.textMuted),
        const SizedBox(width: 10),
        Text(
          '$label:  ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EchoColors.textMuted,
                fontSize: 12,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
