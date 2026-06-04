/// Echo — Memory Detail Screen
///
/// Full memory details with complete toggle and delete.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/memory_service.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;
  const MemoryDetailScreen({super.key, required this.memory});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _memoryService = MemoryService();
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.memory.completed;
  }

  Future<void> _toggleCompleted() async {
    setState(() => _completed = !_completed);
    await _memoryService.toggleCompleted(widget.memory.id, _completed);
  }

  Future<void> _deleteMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: EchoColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _memoryService.deleteMemory(widget.memory.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: EchoColors.error),
            onPressed: _deleteMemory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _completed
                    ? EchoColors.success.withValues(alpha: 0.15)
                    : EchoColors.primary.withValues(alpha: 0.15),
              ),
              child: Text(
                _completed ? '✓ Completed' : '● Active',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _completed ? EchoColors.success : EchoColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.memory.task, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 28),

            _card(context, Icons.textsms_outlined, 'Original Text', widget.memory.originalText),
            const SizedBox(height: 12),
            if (widget.memory.reminderDate != null) ...[
              _card(context, Icons.schedule_rounded, 'Reminder', _fmtDate(widget.memory.reminderDate!)),
              const SizedBox(height: 12),
            ],
            _card(context, Icons.notifications_outlined, 'Type', widget.memory.reminderType.toUpperCase()),
            const SizedBox(height: 12),
            _card(context, Icons.access_time, 'Created', DateFormat('MMM d, yyyy – h:mm a').format(widget.memory.createdAt)),
            const SizedBox(height: 32),

            // Toggle button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: _completed ? null : EchoDecorations.gradientButton(),
                child: ElevatedButton.icon(
                  onPressed: _toggleCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _completed ? EchoColors.surfaceLight : Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(_completed ? Icons.replay : Icons.check_circle_outline, size: 20),
                  label: Text(_completed ? 'Mark as Active' : 'Mark as Completed',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext ctx, IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: EchoDecorations.glassCard(opacity: 0.06),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: EchoColors.primary.withValues(alpha: 0.12)),
          child: Icon(icon, size: 17, color: EchoColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(ctx).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(fontSize: 14)),
        ])),
      ]),
    );
  }

  String _fmtDate(String s) {
    try {
      final d = DateTime.parse(s);
      return (d.hour != 0 || d.minute != 0)
          ? DateFormat('EEEE, MMM d, yyyy – h:mm a').format(d)
          : DateFormat('EEEE, MMM d, yyyy').format(d);
    } catch (_) { return s; }
  }
}
