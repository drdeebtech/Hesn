import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/data/azkar_repository.dart';
import 'package:hesn/models/azkar.dart';

void main() {
  final raw = File('assets/azkar.json').readAsStringSync();

  group('azkar.json content integrity (Principle I)', () {
    test('parses into morning + evening lists', () {
      final lists = AzkarRepository.parse(raw);
      expect(lists.map((l) => l.id), containsAll(['morning', 'evening']));
      for (final l in lists) {
        expect(l.items, isNotEmpty);
      }
    });

    test('every quran item has a non-empty ref', () {
      final lists = AzkarRepository.parse(raw);
      for (final l in lists) {
        for (final it in l.items) {
          if (it.type == AzkarType.quran) {
            expect(it.ref, isNotNull, reason: '${it.id} missing ref');
            expect(it.ref!.isNotEmpty, isTrue);
          }
        }
      }
    });

    test('every repeat count is >= 1', () {
      final lists = AzkarRepository.parse(raw);
      for (final l in lists) {
        for (final it in l.items) {
          expect(it.repeat, greaterThanOrEqualTo(1));
        }
      }
    });

    test('every multi-repeat item carries a countPhrase (FR-025)', () {
      final lists = AzkarRepository.parse(raw);
      for (final l in lists) {
        for (final it in l.items) {
          if (it.repeat > 1) {
            expect(it.countPhrase, isNotNull,
                reason: '${it.id} (repeat ${it.repeat}) missing countPhrase');
            expect(it.countPhrase!.trim().isNotEmpty, isTrue);
          }
        }
      }
    });

    test('parsing does not trim/normalize text (byte-stable round-trip)', () {
      // The parsed text must equal exactly what is in the JSON value.
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lists = AzkarRepository.parse(raw);
      for (var li = 0; li < lists.length; li++) {
        final items = (decoded[li]['items'] as List<dynamic>);
        for (var ii = 0; ii < lists[li].items.length; ii++) {
          expect(lists[li].items[ii].text, items[ii]['text']);
        }
      }
    });
  });
}
