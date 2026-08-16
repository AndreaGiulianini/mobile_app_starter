import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_event.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_state.dart';
import 'package:mobile_app_starter/widgets/favorite_button.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FavoriteButton', () {
    testWidgets('shows the outline heart and dispatches FavoriteToggled', (
      WidgetTester tester,
    ) async {
      final MockFavoritesBloc favorites = MockFavoritesBloc();
      whenListen(
        favorites,
        const Stream<FavoritesState>.empty(),
        initialState: const FavoritesState(),
      );

      await tester.pumpApp(
        const Scaffold(body: FavoriteButton(pokemonId: 25)),
        favoritesBloc: favorites,
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      await tester.tap(find.byType(IconButton));
      verify(() => favorites.add(const FavoriteToggled(25))).called(1);
    });

    testWidgets('shows the filled heart when the id is favourited', (
      WidgetTester tester,
    ) async {
      final MockFavoritesBloc favorites = MockFavoritesBloc();
      whenListen(
        favorites,
        const Stream<FavoritesState>.empty(),
        initialState: const FavoritesState(ids: <int>{25}),
      );

      await tester.pumpApp(
        const Scaffold(body: FavoriteButton(pokemonId: 25)),
        favoritesBloc: favorites,
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('meets the minimum tap target size', (
      WidgetTester tester,
    ) async {
      final MockFavoritesBloc favorites = MockFavoritesBloc();
      whenListen(
        favorites,
        const Stream<FavoritesState>.empty(),
        initialState: const FavoritesState(),
      );

      // iconSize 18 is the card's compact configuration; the hit area must
      // not shrink with the glyph.
      await tester.pumpApp(
        const Scaffold(body: FavoriteButton(pokemonId: 25, iconSize: 18)),
        favoritesBloc: favorites,
      );
      await tester.pump();

      final Size size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });
  });
}
