/// Converts Western digits in a string (or an int) to Arabic-Indic numerals
/// (٠١٢٣٤٥٦٧٨٩). Used for counters and the repeat chip in the RTL UI.
const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabicDigits(Object value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (final ch in s.runes) {
    if (ch >= 0x30 && ch <= 0x39) {
      buf.write(_arabicDigits[ch - 0x30]);
    } else {
      buf.writeCharCode(ch);
    }
  }
  return buf.toString();
}
