import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Today's completion status as a tinted pill (RTL).
class ProgressBadge extends StatelessWidget {
  const ProgressBadge({super.key, required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final success = Theme.of(context).extension<HesnColors>()!.success;
    final fg = completed ? success : cs.onSurfaceVariant;
    final bg = completed ? success.withValues(alpha: 0.12) : cs.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(completed ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: fg, size: 18),
          const SizedBox(width: 6),
          Text(
            completed ? 'اكتمل اليوم' : 'لم يكتمل',
            style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
