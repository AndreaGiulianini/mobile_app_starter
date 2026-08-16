import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/search_field.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<MockSearchBloc> pumpField(
    WidgetTester tester, {
    SearchState initialState = const SearchIdle(),
  }) async {
    final MockSearchBloc search = MockSearchBloc();
    whenListen(
      search,
      const Stream<SearchState>.empty(),
      initialState: initialState,
    );
    await tester.pumpApp(
      Scaffold(appBar: AppBar(title: const SearchField())),
      searchBloc: search,
    );
    await tester.pump();
    return search;
  }

  group('SearchField', () {
    testWidgets('the clear button clears the text AND resets the bloc', (
      WidgetTester tester,
    ) async {
      // The two-step is exactly what regresses: clearing the controller
      // without the event leaves stale results, the reverse leaves stale text.
      final MockSearchBloc search = await pumpField(
        tester,
        initialState: const SearchLoading(),
      );

      await tester.enterText(find.byType(TextField), 'pika');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      verify(() => search.add(const SearchCleared())).called(1);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('emptying the field by backspace resets immediately', (
      WidgetTester tester,
    ) async {
      // Deleting the last character must not wait out the debounce window:
      // it dispatches SearchCleared, not SearchQueryChanged('').
      final MockSearchBloc search = await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'p');
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      verify(() => search.add(const SearchQueryChanged('p'))).called(1);
      verify(() => search.add(const SearchCleared())).called(1);
    });

    testWidgets('no clear button while idle', (WidgetTester tester) async {
      await pumpField(tester);

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });
}
