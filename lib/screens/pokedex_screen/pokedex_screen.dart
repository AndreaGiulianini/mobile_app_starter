import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/search_field.dart';
import 'package:mobile_app_starter/widgets/app_state_views.dart';
import 'package:mobile_app_starter/widgets/pokemon_grid.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double _scrollThreshold = 0.9;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // The view owns the initial load, not the cubit's constructor: a fetch
    // started there is unawaitable and unstubbable. Post-frame because
    // `context.read` is not available during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PokemonCubit>().loadPokemon();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokemonCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.offset;
    // maxScrollExtent is 0 before the first layout, which would otherwise
    // read as "already at the bottom" while the list is at rest.
    return maxScroll > 0 && currentScroll >= (maxScroll * _scrollThreshold);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // Styling comes from `appBarTheme`: overriding colors here forced the
    // light-mode primary onto the dark theme's surface app bar.
    appBar: AppBar(title: const SearchField()),
    // BlocListeners, not BlocBuilders: these failures are notifications, not
    // screens.
    body: MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<SearchBloc, SearchState>(
          listenWhen: (SearchState previous, SearchState current) =>
              current is SearchFailure,
          listener: (BuildContext context, SearchState state) {
            if (state is SearchFailure) {
              _showSnackBar(
                context,
                state.message ?? AppLocalizations.of(context).searchFailed,
              );
            }
          },
        ),
        // A failed loadMore keeps the list on screen; this is its only signal.
        BlocListener<PokemonCubit, PokemonState>(
          listenWhen: (PokemonState previous, PokemonState current) =>
              current is PokemonSuccess && current.loadMoreFailed,
          listener: (BuildContext context, PokemonState state) => _showSnackBar(
            context,
            AppLocalizations.of(context).pokedexLoadMoreFailed,
          ),
        ),
      ],
      child: BlocBuilder<SearchBloc, SearchState>(
        // Swapping between two states that render the same body must not
        // rebuild the whole grid.
        buildWhen: (SearchState previous, SearchState current) =>
            !(_showsPaginatedBody(previous) && _showsPaginatedBody(current)),
        builder: (BuildContext context, SearchState searchState) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          return switch (searchState) {
            // Keep in step with _showsPaginatedBody.
            SearchIdle() || SearchFailure() => _PokedexBody(
              scrollController: _scrollController,
            ),
            SearchLoading() => const AppLoadingView(),
            SearchEmpty(:final String query) => AppEmptyView(
              message: l10n.searchNoResults(query),
            ),
            SearchSuccess(:final List<Pokemon> results) => PokemonGrid(
              pokemonList: results,
              header: l10n.searchResultCount(results.length),
            ),
          };
        },
      ),
    ),
  );
}

/// Replaces whatever is already showing, so two failures in a row do not
/// queue up behind each other.
void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Whether [state] renders the paginated list rather than search results: a
/// failed search stays on the list and reports itself with a SnackBar.
bool _showsPaginatedBody(SearchState state) =>
    state is SearchIdle || state is SearchFailure;

/// The paginated list, shown whenever no search is active.
class _PokedexBody extends StatelessWidget {
  const _PokedexBody({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<PokemonCubit, PokemonState>(
      builder: (BuildContext context, PokemonState state) {
        return switch (state) {
          PokemonInitial() ||
          PokemonLoading() => AppLoadingView(message: l10n.pokedexLoading),
          PokemonError(:final String message) => AppErrorView.withRetry(
            message: message,
            retryLabel: l10n.pokedexRetry,
            onRetry: () => context.read<PokemonCubit>().retry(),
          ),
          PokemonSuccess(:final List<Pokemon> pokemonList) =>
            pokemonList.isEmpty
                ? AppEmptyView(message: l10n.pokedexEmpty)
                : PokemonGrid(
                    pokemonList: pokemonList,
                    controller: scrollController,
                  ),
          PokemonLoadingMore(:final List<Pokemon> currentList) => PokemonGrid(
            pokemonList: currentList,
            controller: scrollController,
            footer: AppLoadingMoreIndicator(message: l10n.pokedexLoadingMore),
          ),
        };
      },
    );
  }
}
