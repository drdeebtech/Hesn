import 'package:flutter/material.dart';

/// Today's completion status for a list (RTL).
class ProgressBadge extends StatelessWidget {
  const ProgressBadge({super.key, required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? scheme.primary : scheme.outline,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(completed ? 'تم اليوم' : 'لم يكتمل'),
      ],
    );
  }
}
