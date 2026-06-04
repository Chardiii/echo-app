/// Echo — Memory Card Widget
///
/// Glassmorphism card for displaying memories in the home screen list.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/memory_service.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggle;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: EchoDecorations.glassCard(
          opacity: memory.completed ? 0.04 : 0.08,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => onToggle?.call(!memory.completed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: memory.completed
                        ? EchoColors.primaryGradient
                        : null,
                    border: memory.completed
                        ? null
                        : Border.all(
                            color: EchoColors.textMuted,
                            width: 1.5,
                          ),
                  ),
                  child: memory.completed
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      memory.task,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: memory.completed
                            ? EchoColors.textMuted
                            : EchoColors.textPrimary,
                        decoration: memory.completed
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: EchoColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (memory.reminderDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: memory.completed
                                ? EchoColors.textMuted
                                : EchoColors.secondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(memory.reminderDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: memory.completed
                                  ? EchoColors.textMuted
                                  : EchoColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: EchoColors.textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final diff = dateOnly.difference(today).inDays;

      String dayLabel;
      if (diff == 0) {
        dayLabel = 'Today';
      } else if (diff == 1) {
        dayLabel = 'Tomorrow';
      } else if (diff == -1) {
        dayLabel = 'Yesterday';
      } else if (diff > 0 && diff < 7) {
        dayLabel = DateFormat('EEEE').format(date);
      } else {
        dayLabel = DateFormat('MMM d').format(date);
      }

      // Add time if present
      if (date.hour != 0 || date.minute != 0) {
        dayLabel += ' at ${DateFormat('h:mm a').format(date)}';
      }

      return dayLabel;
    } catch (_) {
      return dateStr;
    }
  }
}
