import 'package:flutter/material.dart';

import '../models/azkar.dart';

/// Renders a fully-voweled azkar phrase: large, scrollable, RTL. Qur'anic items
/// are visually distinguished but never altered.
class AzkarTextView extends StatelessWidget {
  const AzkarTextView({super.key, required this.item});

  final AzkarItem item;

  @override
  Widget build(BuildContext context) {
    final isQuran = item.isQuran;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isQuran)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                item.ref ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          Text(
            item.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: isQuran ? 30 : 28,
              height: 1.9,
              fontWeight: isQuran ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
