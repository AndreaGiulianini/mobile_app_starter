import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/extensions/string_extensions.dart';
import 'package:mobile_app_starter/widgets/ability_chip.dart';
import 'package:mobile_app_starter/widgets/labelled_value_row.dart';
import 'package:mobile_app_starter/widgets/pokemon_type_chip.dart';
import 'package:mobile_app_starter/widgets/stat_bar.dart';

import '../helpers/pump_app.dart';

void main() {
  group('StringCasing', () {
    test('capitalized only touches the first character', () {
      expect('bulbasaur'.capitalized, 'Bulbasaur');
      expect(''.capitalized, '');
      expect('a'.capitalized, 'A');
    });

    test('titleCased splits on hyphens, as the API keys do', () {
      expect('special-attack'.titleCased, 'Special Attack');
      expect('static'.titleCased, 'Static');
    });
  });

  group('PokemonTypeChip', () {
    testWidgets('both sizes render a capitalised label', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(
        const Scaffold(
          body: Column(
            children: <Widget>[
              PokemonTypeChip.small(type: 'electric'),
              PokemonTypeChip.large(type: 'flying'),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Electric'), findsOneWidget);
      expect(find.text('Flying'), findsOneWidget);
    });

    testWidgets('sizes to its content, not to the parent constraints', (
      WidgetTester tester,
    ) async {
      // Regression: the chip used Container's `alignment`, which makes a
      // Container expand to fill its constraints. It stayed compact inside the
      // card's unbounded horizontal ListView but stretched full-width inside
      // the detail screen's Wrap.
      await tester.pumpApp(
        const Scaffold(
          body: SizedBox(
            width: 400,
            child: Wrap(
              children: <Widget>[PokemonTypeChip.large(type: 'grass')],
            ),
          ),
        ),
      );
      await tester.pump();

      final double width = tester.getSize(find.byType(PokemonTypeChip)).width;
      expect(
        width,
        lessThan(200),
        reason:
            'the chip stretched to fill its parent instead of hugging '
            'its label (measured ${width.toStringAsFixed(1)} of 400)',
      );
    });

    testWidgets('large is taller than small', (WidgetTester tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: Column(
            children: <Widget>[
              PokemonTypeChip.small(type: 'fire'),
              PokemonTypeChip.large(type: 'water'),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.text('Water').first).height,
        greaterThan(tester.getSize(find.text('Fire').first).height),
      );
    });
  });

  group('AbilityChip', () {
    testWidgets('marks hidden abilities and title-cases the name', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(
        const Scaffold(
          body: Column(
            children: <Widget>[
              AbilityChip(
                name: 'lightning-rod',
                isHidden: true,
                hiddenLabel: 'hidden',
              ),
              AbilityChip(
                name: 'static',
                isHidden: false,
                hiddenLabel: 'hidden',
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Lightning Rod (hidden)'), findsOneWidget);
      expect(find.text('Static'), findsOneWidget);
    });
  });

  group('StatBar', () {
    testWidgets('shows label and value, and clamps the bar to 0..1', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(
        const Scaffold(
          body: Column(
            children: <Widget>[
              StatBar(label: 'HP', value: 45),
              // Above the 255 maximum: must not produce an out-of-range value.
              StatBar(label: 'Attack', value: 900),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('HP'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      for (final LinearProgressIndicator bar
          in tester.widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )) {
        expect(bar.value, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('LabelledValueRow', () {
    testWidgets('renders both sides', (WidgetTester tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: LabelledValueRow(label: 'Height', value: '0.7 m'),
        ),
      );
      await tester.pump();

      expect(find.text('Height'), findsOneWidget);
      expect(find.text('0.7 m'), findsOneWidget);
    });
  });
}
