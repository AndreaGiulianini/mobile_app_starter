import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/router/routes.dart';
import 'package:mobile_app_starter/screens/pokedex_screen/widgets/pokemon_card.dart';
import 'package:mobile_app_starter/service/client.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  List<Pokemon>? _pokemonList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPokemon());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pokédex'),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[CircularProgressIndicator(), SizedBox(height: 16), Text('Loading Pokémon...')],
            ),
          )
        : _pokemonList == null || _pokemonList!.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Failed to load Pokémon'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadPokemon, child: const Text('Retry')),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _pokemonList!.length,
              itemBuilder: (BuildContext context, int index) {
                return PokemonCard(pokemon: _pokemonList![index]);
              },
            ),
          ),
    floatingActionButton: _pokemonList != null && _pokemonList!.isNotEmpty
        ? FloatingActionButton(onPressed: onPressed, child: const Icon(Icons.arrow_forward))
        : null,
  );

  void onPressed() {
    HomeScreenPage().go(context);
  }

  Future<void> _loadPokemon() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First, get the list of Pokemon
      final List<Pokemon> basicList = await ClientAPI().getListPokemon();

      // Then, fetch detailed info for each Pokemon
      final List<Pokemon> detailedList = <Pokemon>[];
      for (final Pokemon pokemon in basicList) {
        if (pokemon.url == null) {
          detailedList.add(pokemon);
          continue;
        }

        try {
          final Pokemon detailed = await ClientAPI().getPokemonDetails(pokemon.url!);
          detailedList.add(detailed);

          // Update UI progressively as we load each Pokemon
          if (mounted) {
            setState(() {
              _pokemonList = List<Pokemon>.from(detailedList);
            });
          }
        } catch (e) {
          // If fetching details fails, add the basic Pokemon
          detailedList.add(pokemon);
        }
      }

      if (mounted) {
        setState(() {
          _pokemonList = detailedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pokemonList = null;
          _isLoading = false;
        });
      }
    }
  }
}
