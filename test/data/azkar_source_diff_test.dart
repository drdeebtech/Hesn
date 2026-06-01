import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/data/azkar_repository.dart';

/// Constitution Principle I / SC-008: every recited phrase in azkar.json must
/// appear verbatim (character-for-character) in the committed Hisn al-Muslim
/// source. The source wraps phrases in delimiters and count annotations, so we
/// check that each item's text is an exact substring of the source.
void main() {
  test('every azkar text is a verbatim substring of the committed source', () {
    final source =
        File('specs/001-azkar-session/source/azkar-source.txt').readAsStringSync();
    final lists =
        AzkarRepository.parse(File('assets/azkar.json').readAsStringSync());

    final missing = <String>[];
    for (final l in lists) {
      for (final it in l.items) {
        if (!source.contains(it.text)) missing.add('${l.id}/${it.id}');
      }
    }
    expect(missing, isEmpty,
        reason: 'These items are not verbatim in the source: '
            '${missing.join(', ')}');
  });
}
