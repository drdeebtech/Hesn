import 'package:flutter/material.dart';

import '../models/azkar.dart';
import '../theme/app_theme.dart';

/// Renders a fully-voweled azkar phrase as the Session hero: large Amiri Naskh,
/// centered, RTL, never truncated (auto-fits down to a legible floor, then
/// scrolls). Qur'anic items use the lighter Quran style with a gold ref label.
class AzkarTextView extends StatelessWidget {
  const AzkarTextView({super.key, required this.item});

  final AzkarItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isQuran = item.isQuran;
    final style = (isQuran ? AppTheme.azkarQuran : AppTheme.azkarDisplay)
        .copyWith(color: cs.onSurface);

    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Text(
          item.text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: style,
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isQuran && item.ref != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '﴿ ${item.ref} ﴾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                // Auto-fit down to a legible floor (28sp); scroll handles the rest.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: text,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
