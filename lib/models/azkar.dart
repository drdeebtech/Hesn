import 'package:flutter/foundation.dart';

/// Kind of an azkar item. `quran` items are immutable Qur'anic verses
/// (Constitution Principle I) and must carry a [AzkarItem.ref].
enum AzkarType { dhikr, quran }

AzkarType _typeFromString(String s) {
  switch (s) {
    case 'dhikr':
      return AzkarType.dhikr;
    case 'quran':
      return AzkarType.quran;
    default:
      throw FormatException('Unknown azkar type: "$s"');
  }
}

/// A single phrase to display, recite, and advance past.
///
/// Text and [repeat] come from Hisn al-Muslim verbatim and MUST NOT be altered
/// by application logic. [repeat] is display-only and never drives auto-advance
/// (Constitution Principle IV).
@immutable
class AzkarItem {
  const AzkarItem({
    required this.id,
    required this.type,
    required this.text,
    required this.repeat,
    required this.source,
    this.ref,
  });

  final String id;
  final AzkarType type;

  /// Fully voweled Arabic text, verbatim. Never trimmed/normalized.
  final String text;

  /// Number of repetitions per the source. Shown to the user; the user counts.
  final int repeat;

  /// Attribution, e.g. "حصن المسلم".
  final String source;

  /// surah:ayah (e.g. "2:255" or "112:1-4"). Required iff [type] is quran.
  final String? ref;

  bool get isQuran => type == AzkarType.quran;

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    final type = _typeFromString(json['type'] as String);
    final id = json['id'] as String;
    final text = json['text'] as String;
    final repeat = json['repeat'] as int;
    final source = json['source'] as String;
    final ref = json['ref'] as String?;

    if (id.isEmpty) throw const FormatException('AzkarItem.id must not be empty');
    if (text.isEmpty) throw FormatException('AzkarItem "$id" has empty text');
    if (repeat < 1) throw FormatException('AzkarItem "$id" repeat must be >= 1');
    if (source.isEmpty) throw FormatException('AzkarItem "$id" missing source');
    if (type == AzkarType.quran && (ref == null || ref.isEmpty)) {
      throw FormatException('Quran item "$id" must have a non-empty ref');
    }
    return AzkarItem(
      id: id,
      type: type,
      text: text,
      repeat: repeat,
      source: source,
      ref: ref,
    );
  }
}

/// An ordered list of items for one period (morning or evening).
@immutable
class AzkarList {
  const AzkarList({required this.id, required this.title, required this.items});

  /// `morning` or `evening`.
  final String id;

  /// Arabic title, e.g. "أذكار الصباح".
  final String title;

  final List<AzkarItem> items;

  int get length => items.length;

  factory AzkarList.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final title = json['title'] as String;
    final rawItems = (json['items'] as List<dynamic>);
    if (rawItems.isEmpty) {
      throw FormatException('AzkarList "$id" must have at least one item');
    }
    final items = rawItems
        .map((e) => AzkarItem.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return AzkarList(id: id, title: title, items: items);
  }
}
