import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_starter/cubit/pokemon_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final ScrollController _scrollController = ScrollController();

  // Constants
  static const double _scrollThreshold = 0.9;
  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      );

  @override
  void initState() {
    super.initState();
    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);

    // Defer context access until after first frame
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
    return currentScroll >= (maxScroll * _scrollThreshold);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pokédex'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 4,
    ),
    body: BlocBuilder<PokemonCubit, PokemonState>(
      builder: (BuildContext context, PokemonState state) {
        if (state is PokemonInitial || state is PokemonLoading) {
          return _buildLoadingState(state);
        }

        if (state is PokemonError) {
          return _buildErrorState(state);
        }

        if (state is PokemonSuccess) {
          return _buildSuccessState(state.pokemonList, state.hasMore);
        }

        if (state is PokemonLoadingMore) {
          return _buildSuccessState(
            state.currentList,
            true,
            isLoadingMore: true,
          );
        }

        return const SizedBox.shrink();
      },
    ),
  );

  Widget _buildLoadingState(PokemonState state) {
    final List<Pokemon>? partialList = state is PokemonLoading
        ? state.partialList
        : null;

    if (partialList != null && partialList.isNotEmpty) {
      // Show progressive loading with partial data
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: _gridDelegate,
          itemCount: partialList.length,
          itemBuilder: (BuildContext context, int index) {
            final Pokemon pokemon = partialList[index];
            return PokemonCard(
              key: ValueKey<int>(pokemon.pokemonId),
              pokemon: pokemon,
            );
          },
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading Pokémon...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(PokemonError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(state.message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<PokemonCubit>().retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    List<Pokemon> pokemonList,
    bool hasMore, {
    bool isLoadingMore = false,
  }) {
    // Handle empty state
    if (pokemonList.isEmpty) {
      return const Center(child: Text('No Pokémon found'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: _gridDelegate,
              itemCount: pokemonList.length,
              itemBuilder: (BuildContext context, int index) {
                final Pokemon pokemon = pokemonList[index];
                return PokemonCard(
                  key: ValueKey<int>(pokemon.pokemonId),
                  pokemon: pokemon,
                );
              },
            ),
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading more Pokémon...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
