import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_bloc.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_event.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_state.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage;

void main() {
  late MockStorage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    HydratedBloc.storage = storage;
  });

  group('FavoritesBloc', () {
    test('starts empty when storage has nothing', () {
      expect(FavoritesBloc().state, const FavoritesState());
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoriteToggled adds an absent id',
      build: FavoritesBloc.new,
      act: (FavoritesBloc bloc) => bloc.add(const FavoriteToggled(25)),
      expect: () => <FavoritesState>[
        const FavoritesState(ids: <int>{25}),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoriteToggled removes an id that is already there',
      build: FavoritesBloc.new,
      seed: () => const FavoritesState(ids: <int>{25, 1}),
      act: (FavoritesBloc bloc) => bloc.add(const FavoriteToggled(25)),
      expect: () => <FavoritesState>[
        const FavoritesState(ids: <int>{1}),
      ],
    );

    test('persists through toJson and restores through fromJson', () {
      final FavoritesBloc bloc = FavoritesBloc();
      const FavoritesState state = FavoritesState(ids: <int>{1, 25});

      final Map<String, dynamic>? json = bloc.toJson(state);
      expect(json, isNotNull);

      expect(bloc.fromJson(json!), state);
    });

    test('fromJson tolerates a malformed payload instead of throwing', () {
      // Storage can hold anything an older build wrote; null makes
      // hydrated_bloc fall back to the initial state instead of crashing.
      final FavoritesBloc bloc = FavoritesBloc();
      expect(bloc.fromJson(<String, dynamic>{'ids': 'not-a-list'}), isNull);
      expect(bloc.fromJson(<String, dynamic>{}), isNull);
    });

    test('restores previously stored favourites on construction', () {
      when(() => storage.read(any())).thenReturn(<String, dynamic>{
        'ids': <int>[7, 42],
      });

      expect(FavoritesBloc().state.ids, <int>{7, 42});
    });

    test('toJson stamps the schema version', () {
      final Map<String, dynamic>? json = FavoritesBloc().toJson(
        const FavoritesState(ids: <int>{1}),
      );

      expect(json?['v'], 1);
    });

    test('fromJson reads the unversioned legacy payload', () {
      // Payloads written before versioning have no 'v'; they must migrate,
      // not be clobbered.
      final FavoritesBloc bloc = FavoritesBloc();

      expect(
        bloc.fromJson(<String, dynamic>{
          'ids': <int>[7],
        })?.ids,
        <int>{7},
      );
    });

    test('fromJson refuses an unknown future schema version', () {
      final FavoritesBloc bloc = FavoritesBloc();

      expect(
        bloc.fromJson(<String, dynamic>{
          'v': 99,
          'ids': <int>[7],
        }),
        isNull,
      );
    });

    test('fromJson coerces JSON-widened doubles back to ints', () {
      // A JSON round-trip (always, on web) widens ints to doubles; filtering
      // on `int` alone silently erased every favourite.
      final FavoritesBloc bloc = FavoritesBloc();

      expect(
        bloc.fromJson(<String, dynamic>{
          'v': 1,
          'ids': <double>[7.0, 42.0],
        })?.ids,
        <int>{7, 42},
      );
    });
  });
}
