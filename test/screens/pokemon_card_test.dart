import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/pokemon_card.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

/// The cell the Pokédex grid actually hands a card on a 411dp-wide phone:
/// (411.4 - 16 padding - 8 spacing) / 2, at childAspectRatio 0.75.
///
/// Measured rather than guessed — at a roomier size the original bug did not
/// reproduce at all.
const Size _gridCell = Size(193.7, 258.3);

void main() {
  Future<void> pumpCard(WidgetTester tester, Pokemon pokemon) {
    return tester.pumpApp(
      Scaffold(
        body: Center(
          child: SizedBox(
            width: _gridCell.width,
            height: _gridCell.height,
            child: PokemonCard(pokemon: pokemon),
          ),
        ),
      ),
    );
  }

  group('PokemonCard layout', () {
    // The bug: the info column mixed MainAxisSize.min with a Spacer, so a
    // Pokémon with two types wrapped its chips onto a second line and the
    // height/weight row drew on top of them. Measured before the fix, "H:"
    // spanned y 558.3-574.3 while the Electric chip spanned 548.2-562.2.
    for (final List<String> types in <List<String>>[
      <String>['electric'],
      <String>['grass', 'poison'],
      <String>['fire', 'flying', 'dragon'],
    ]) {
      testWidgets('stats clear the type chips with ${types.length} type(s)', (
        WidgetTester tester,
      ) async {
        await pumpCard(
          tester,
          buildPokemon(id: 25, name: 'pikachu', types: types),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'the card overflowed its grid cell',
        );

        final Rect stats = tester.getRect(find.textContaining('H:'));
        for (final String type in types) {
          final Finder chip = find.text(
            type[0].toUpperCase() + type.substring(1),
          );
          if (chip.evaluate().isEmpty) {
            continue;
          }
          expect(
            tester.getRect(chip).bottom,
            lessThanOrEqualTo(stats.top),
            reason: 'the "$type" chip overlaps the height/weight row',
          );
        }
      });
    }

    testWidgets('survives a long name and long type names', (
      WidgetTester tester,
    ) async {
      await pumpCard(
        tester,
        buildPokemon(
          id: 999,
          name: 'crabominable-gigantamax-form',
          types: <String>['fighting', 'special-defense-ish', 'electric'],
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows number, name, type and both stats', (
      WidgetTester tester,
    ) async {
      await pumpCard(
        tester,
        buildPokemon(id: 25, name: 'pikachu', types: <String>['electric']),
      );
      await tester.pump();

      expect(find.text('#025'), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Electric'), findsOneWidget);
      // Both were pushed out of the card by the old layout.
      expect(find.textContaining('H:'), findsOneWidget);
      expect(find.textContaining('W:'), findsOneWidget);
    });
  });
}
