import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/azkar.dart';

/// Loads the read-only azkar content from `assets/azkar.json`.
///
/// Text is parsed verbatim — no trimming, normalization, or transformation
/// (Constitution Principle I).
class AzkarRepository {
  AzkarRepository({this.assetPath = 'assets/azkar.json'});

  final String assetPath;
  List<AzkarList>? _cache;

  Future<List<AzkarList>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    _cache = parse(raw);
    return _cache!;
  }

  Future<AzkarList> byId(String id) async {
    final all = await loadAll();
    return all.firstWhere(
      (l) => l.id == id,
      orElse: () => throw ArgumentError('No azkar list with id "$id"'),
    );
  }

  /// Parses the JSON string into lists. Exposed for testing.
  static List<AzkarList> parse(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => AzkarList.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
