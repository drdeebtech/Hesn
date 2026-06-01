import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Constitution Principle III / FR-021: the app must make no network calls.
/// This guard fails if a network dependency is declared or a networking API is
/// imported in lib/.
void main() {
  test('no network dependency in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    const banned = ['http:', 'dio:', 'web_socket_channel:', 'grpc:', 'http2:'];
    for (final b in banned) {
      expect(pubspec.contains(b), isFalse,
          reason: 'Banned network dependency "$b" found in pubspec.yaml');
    }
  });

  test('no networking imports/usage in lib/', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final offenders = <String>[];
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      final usesHttpPackage = src.contains("package:http/");
      // dart:io HttpClient / Socket usage (rootBundle/File are fine).
      final usesIoNetworking =
          RegExp(r'\bHttpClient\b').hasMatch(src) ||
              RegExp(r'\bSocket\.connect\b').hasMatch(src) ||
              RegExp(r'\bRawSocket\b').hasMatch(src);
      if (usesHttpPackage || usesIoNetworking) offenders.add(f.path);
    }
    expect(offenders, isEmpty,
        reason: 'Networking usage found in: ${offenders.join(', ')}');
  });
}
