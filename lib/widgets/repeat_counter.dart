import 'package:flutter/material.dart';

/// Shows the source repeat count for the current phrase. Display-only — the
/// user counts repeats themselves (Constitution Principle IV).
class RepeatCounter extends StatelessWidget {
  const RepeatCounter({super.key, required this.repeat});

  final int repeat;

  @override
  Widget build(BuildContext context) {
    if (repeat <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'التكرار: $repeat',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
