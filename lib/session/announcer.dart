import '../models/azkar.dart';

/// Pure-Dart helper for hands-free (driving) mode: decides what the app speaks
/// before reading a phrase. Keeps announcement logic out of the controller and
/// trivially unit-testable.
class Announcer {
  const Announcer();

  /// The spoken repeat-count announcement for [item], or null when there is
  /// nothing to announce (count of 1, or no canonical phrase available).
  /// Uses the item's source-canonical [AzkarItem.countPhrase] (FR-025).
  String? countAnnouncement(AzkarItem item) {
    if (item.repeat <= 1) return null;
    return item.countPhrase;
  }

  /// Spoken cue when a list session begins.
  String sessionStart(AzkarList list) => list.title;

  /// Spoken cue when a list session is completed.
  String sessionComplete(AzkarList list) => 'اكتملت ${list.title}';
}
