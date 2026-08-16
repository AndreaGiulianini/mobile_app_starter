import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mobile_app_starter/screens/pokemon_detail_screen/pokemon_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

/// The screen builds its own cubit from the provided repository, so these
/// tests exercise the route-scoped BlocProvider and the post-frame load too.
void main() {
  late MockPokemonRepository repository;

  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    repository = MockPokemonRepository();
  });

  group('PokemonDetailScreen', () {
    testWidgets('shows a spinner while loading, then the Pokémon', (
      WidgetTester tester,
    ) async {
      when(() => repository.getById(25, cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => buildPokemon(id: 25, name: 'pikachu'));

      await tester.pumpApp(
        const PokemonDetailScreen(id: 25),
        repository: repository,
      );
      // Before the mocked fetch resolves, the loading branch is on screen.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('#025'), findsOneWidget);
      // The fixture's single type, capitalised by the chip.
      expect(find.text('Grass'), findsOneWidget);
      // Height/weight rows render localized values.
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('surfaces the AppException message with a Retry button', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getById(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(const NotFoundException('no such pokemon'));

      await tester.pumpApp(
        const PokemonDetailScreen(id: 9999),
        repository: repository,
      );
      await tester.pumpAndSettle();

      expect(find.text('no such pokemon'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('localizes the fallback for unexpected errors', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getById(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(Exception('boom'));

      await tester.pumpApp(
        const PokemonDetailScreen(id: 1),
        repository: repository,
      );
      await tester.pumpAndSettle();

      // The English detailLoadFailed ARB value: the state carries null and
      // the widget layer localizes.
      expect(find.text('Could not load this Pokémon.'), findsOneWidget);
    });

    testWidgets('Retry reloads after a failure', (WidgetTester tester) async {
      int calls = 0;
      when(() => repository.getById(1, cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async {
            if (calls++ == 0) {
              throw const NetworkException('offline');
            }
            return buildPokemon(id: 1, name: 'bulbasaur');
          });

      await tester.pumpApp(
        const PokemonDetailScreen(id: 1),
        repository: repository,
      );
      await tester.pumpAndSettle();
      expect(find.text('offline'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Bulbasaur'), findsOneWidget);
    });
  });
}
