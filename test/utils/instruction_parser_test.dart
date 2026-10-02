import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_explorer/utils/instruction_parser.dart';

void main() {
  group('InstructionParser.parse', () {
    test('splits on line breaks and drops blank lines', () {
      expect(
        InstructionParser.parse('Mix flour.\r\n\r\nAdd eggs.\nBake.'),
        ['Mix flour.', 'Add eggs.', 'Bake.'],
      );
    });

    test('removes checkbox glyphs left in API text', () {
      expect(
        InstructionParser.parse('Whisk.\r\n☐\r\nSeparate the eggs.'),
        ['Whisk.', 'Separate the eggs.'],
      );
    });

    test('removes the rounded-square glyph TheMealDB actually uses (U+25A2)', () {
      final glyph = String.fromCharCode(0x25A2);
      expect(
        InstructionParser.parse('Whisk.\r\n$glyph\r\nFold in.\n$glyph Bake.'),
        ['Whisk.', 'Fold in.', 'Bake.'],
      );
    });

    test('drops lines holding only invisible characters (U+200B)', () {
      final zeroWidthSpace = String.fromCharCode(0x200B);
      expect(
        InstructionParser.parse('Mix.\r\n$zeroWidthSpace\r\nServe.'),
        ['Mix.', 'Serve.'],
      );
    });

    test('drops lines that are only a step number', () {
      expect(
        InstructionParser.parse('1\r\nBoil water.\r\n2\r\nAdd pasta.'),
        ['Boil water.', 'Add pasta.'],
      );
    });

    test('drops standalone STEP labels and strips inline ones', () {
      expect(
        InstructionParser.parse('STEP 1\r\nPreheat oven.\r\nStep 2: Grease tin.'),
        ['Preheat oven.', 'Grease tin.'],
      );
    });

    test('strips numbered and bullet prefixes', () {
      expect(
        InstructionParser.parse('1. Chop.\n2) Fry.\n3 - Serve.\n- Garnish.\n• Enjoy.'),
        ['Chop.', 'Fry.', 'Serve.', 'Garnish.', 'Enjoy.'],
      );
    });

    test('keeps quantities that merely start with a number', () {
      expect(
        InstructionParser.parse('350 degrees for 20 minutes.\n2 cups of stock go in.'),
        ['350 degrees for 20 minutes.', '2 cups of stock go in.'],
      );
      expect(
        InstructionParser.parse('1.5 litres of water.\n-3 is not a marker'),
        ['1.5 litres of water.', '-3 is not a marker'],
      );
    });

    test('returns an empty list for empty input', () {
      expect(InstructionParser.parse('  \r\n '), isEmpty);
    });
  });
}
