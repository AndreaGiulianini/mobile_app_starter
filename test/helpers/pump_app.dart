import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_bloc.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_event.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_state.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPokemonCubit extends MockCubit<PokemonState> implements PokemonCubit;

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc;

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc;

class MockPokemonRepository extends Mock implements PokemonRepository;

/// Mounts [child] under the four providers and the localization every screen
/// expects. Pass only the doubles you care about; the locale is pinned to
/// English because assertions match the English ARB values.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    PokemonCubit? pokemonCubit,
    SearchBloc? searchBloc,
    FavoritesBloc? favoritesBloc,
    PokemonRepository? repository,
  }) {
    final PokemonCubit pokemon = pokemonCubit ?? buildMockPokemonCubit();
    final SearchBloc search = searchBloc ?? buildMockSearchBloc();
    final FavoritesBloc favorites = favoritesBloc ?? buildMockFavoritesBloc();

    return pumpWidget(
      RepositoryProvider<PokemonRepository>.value(
        value: repository ?? MockPokemonRepository(),
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<PokemonCubit>.value(value: pokemon),
            BlocProvider<SearchBloc>.value(value: search),
            BlocProvider<FavoritesBloc>.value(value: favorites),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: child,
          ),
        ),
      ),
    );
  }
}

/// Sits in [PokemonInitial], with `loadPokemon` stubbed — `initState` fires it
/// in a post-frame callback and mocktail would throw.
PokemonCubit buildMockPokemonCubit() {
  final MockPokemonCubit cubit = MockPokemonCubit();
  when(() => cubit.loadPokemon()).thenAnswer((_) async {});
  when(() => cubit.loadMore()).thenAnswer((_) async {});
  when(() => cubit.retry()).thenAnswer((_) async {});
  whenListen(
    cubit,
    const Stream<PokemonState>.empty(),
    initialState: const PokemonInitial(),
  );
  return cubit;
}

SearchBloc buildMockSearchBloc() {
  final MockSearchBloc bloc = MockSearchBloc();
  whenListen(
    bloc,
    const Stream<SearchState>.empty(),
    initialState: const SearchIdle(),
  );
  return bloc;
}

FavoritesBloc buildMockFavoritesBloc() {
  final MockFavoritesBloc bloc = MockFavoritesBloc();
  whenListen(
    bloc,
    const Stream<FavoritesState>.empty(),
    initialState: const FavoritesState(),
  );
  return bloc;
}
