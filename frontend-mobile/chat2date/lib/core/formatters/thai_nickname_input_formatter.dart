import 'package:flutter/services.dart';

class ThaiNicknameInputFormatter extends TextInputFormatter {
  static const Set<String> _toneMarks = {'่', '้', '๊', '๋'};
  static const Set<String> _otherMarks = {
    'ั',
    'ิ',
    'ี',
    'ึ',
    'ื',
    'ุ',
    'ู',
    'ฺ',
    '็',
    '์',
    'ํ',
    '๎',
  };

  const ThaiNicknameInputFormatter({this.maxCharacters = 20});

  final int maxCharacters;

  bool _isCombiningMark(String char) =>
      _toneMarks.contains(char) || _otherMarks.contains(char);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final source = newValue.text;
    if (source.isEmpty) return newValue;

    final buffer = StringBuffer();
    var clusterHasTone = false;
    var clusterHasOtherMark = false;

    for (final rune in source.runes) {
      final char = String.fromCharCode(rune);

      if (_toneMarks.contains(char)) {
        if (clusterHasTone) continue;
        clusterHasTone = true;
        buffer.write(char);
        continue;
      }

      if (_otherMarks.contains(char)) {
        if (clusterHasOtherMark) continue;
        clusterHasOtherMark = true;
        buffer.write(char);
        continue;
      }

      buffer.write(char);
      if (!_isCombiningMark(char)) {
        clusterHasTone = false;
        clusterHasOtherMark = false;
      }
    }

    final normalized = String.fromCharCodes(
      buffer.toString().runes.take(maxCharacters),
    );
    if (normalized == source) return newValue;

    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }
}
