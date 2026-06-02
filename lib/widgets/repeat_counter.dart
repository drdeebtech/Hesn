import 'package:flutter/material.dart';

import '../util/arabic_numbers.dart';

/// Gold pill showing the source repeat count as "×٣" (Arabic-Indic).
/// Display-only — the user counts repeats themselves (Constitution Principle IV).
class RepeatCounter extends StatelessWidget {
  const RepeatCounter({super.key, required this.repeat});

  final int repeat;

  @override
  Widget build(BuildContext context) {
    if (repeat <= 1) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    // Gold fill + dark on-gold text → AA-safe and keeps the gold identity
    // (gold text on a light surface failed contrast).
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '×${toArabicDigits(repeat)}',
        style: TextStyle(
          color: cs.onSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
