import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/screens/home/widgets/custom_search_bar.dart';

void main() {
  tearDown(Get.reset);

  Future<List<String>> pumpAndSubmit(WidgetTester tester, String query) async {
    final searches = <String>[];
    await tester.pumpWidget(GetMaterialApp(
      home: Scaffold(
        body: CustomSearchBar(
          onSearch: (q, {bool byName = true, bool byIngredient = false}) =>
              searches.add(q),
        ),
      ),
    ));
    await tester.enterText(find.byType(TextField), query);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return searches;
  }

  testWidgets('shows validation feedback for a too-short query', (tester) async {
    final searches = await pumpAndSubmit(tester, 'x');

    expect(searches, isEmpty);
    expect(find.text(TextConstants.invalidSearchTitle), findsOneWidget);

    // Let the snackbar finish so no timers are pending
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('submits a valid query and clears the field', (tester) async {
    final searches = await pumpAndSubmit(tester, '  pasta ');

    expect(searches, ['pasta']);
    expect(find.text(TextConstants.invalidSearchTitle), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });
}
