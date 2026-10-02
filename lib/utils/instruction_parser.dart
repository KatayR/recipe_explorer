/// Turns TheMealDB's free-form `strInstructions` text into clean, ordered steps.
///
/// The API text is inconsistent: steps are separated by (CR)LF, sometimes with
/// blank lines, `STEP 1` / `1.` labels, bullet markers or stray `☐` checkbox glyphs.
class InstructionParser {
  /// Leading step labels/markers to strip: "STEP 1", "Step 2:", "3.", "4)", "5 -", "-", "•", "*",
  /// and lines that are only a step number ("6").
  static final RegExp _stepLabel = RegExp(
    r'^(?:step\s*\d+\s*[:.)\-]?|\d+[.)](?=\s|$)|\d+\s+-|\d+$|[-•*](?=\s))\s*',
    caseSensitive: false,
  );

  /// Checkbox glyphs used as empty step separators: U+25A2 (seen in ~95 API recipes)
  /// and U+2610 BALLOT BOX.
  /// A real step contains at least one letter or digit.
  static final RegExp _hasContent = RegExp(r'[\p{L}\p{N}]', unicode: true);

  static final RegExp _checkbox =
      RegExp('[${String.fromCharCodes(const [0x25A2, 0x2610])}]');

  static List<String> parse(String raw) {
    return raw
        .replaceAll(_checkbox, '')
        .split(RegExp(r'\r?\n|\r'))
        .map((line) => line.trim().replaceFirst(_stepLabel, '').trim())
        // Drops empty lines and invisible leftovers such as zero-width spaces
        .where(_hasContent.hasMatch)
        .toList();
  }
}
