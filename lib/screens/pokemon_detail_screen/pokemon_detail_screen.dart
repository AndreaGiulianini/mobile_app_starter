import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/core/constants/artwork.dart';
import 'package:mobile_app_starter/core/extensions/string_extensions.dart';
import 'package:mobile_app_starter/cubit/pokemon_detail_cubit.dart';
import 'package:mobile_app_starter/cubit/pokemon_detail_state.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mobile_app_starter/widgets/ability_chip.dart';
import 'package:mobile_app_starter/widgets/app_state_views.dart';
import 'package:mobile_app_starter/widgets/favorite_button.dart';
import 'package:mobile_app_starter/widgets/labelled_value_row.dart';
import 'package:mobile_app_starter/widgets/pokemon_type_chip.dart';
import 'package:mobile_app_starter/widgets/section_title.dart';
import 'package:mobile_app_starter/widgets/stat_bar.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    // Provided here so the cubit's lifetime matches the route's.
    return BlocProvider<PokemonDetailCubit>(
      create: (BuildContext context) =>
          PokemonDetailCubit(context.read<PokemonRepository>(), id),
      child: const _PokemonDetailView(),
    );
  }
}

class _PokemonDetailView extends StatefulWidget {
  const _PokemonDetailView();

  @override
  State<_PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<_PokemonDetailView> {
  @override
  void initState() {
    super.initState();
    // The view owns the initial load, same as PokedexScreen: a constructor
    // fetch in the cubit is unawaitable and unstubbable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PokemonDetailCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<PokemonDetailCubit, PokemonDetailState>(
      builder: (BuildContext context, PokemonDetailState state) {
        return switch (state) {
          PokemonDetailLoading() => Scaffold(
            appBar: AppBar(),
            body: const AppLoadingView(),
          ),
          PokemonDetailFailure(:final String? message) => Scaffold(
            appBar: AppBar(),
            body: AppErrorView.withRetry(
              message: message ?? l10n.detailLoadFailed,
              retryLabel: l10n.pokedexRetry,
              onRetry: () => context.read<PokemonDetailCubit>().load(),
            ),
          ),
          PokemonDetailLoaded(:final Pokemon pokemon) => _LoadedView(
            pokemon: pokemon,
          ),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String imageUrl =
        pokemon.sprites?.other?.officialArtwork?.frontDefault ??
        pokemon.sprites?.frontDefault ??
        '';

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name.capitalized),
        actions: <Widget>[
          FavoriteButton(
            pokemonId: pokemon.pokemonId,
            // On the light-mode primary-coloured bar the default red heart
            // would vanish; follow the bar's own foreground instead.
            activeColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Same tag as the list card, so the artwork flies between routes.
          Hero(
            tag: 'pokemon-image-${pokemon.pokemonId}',
            child: Semantics(
              image: true,
              label: pokemon.name.capitalized,
              child: SizedBox(
                height: 220,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.catching_pokemon, size: 120)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        // Decode near the 220dp rendered height, capped at the
                        // source size.
                        memCacheHeight: math.min(
                          kArtworkSourcePx,
                          (220 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                        ),
                        placeholder: (BuildContext context, String url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (
                          BuildContext context,
                          String url,
                          Object error,
                        ) => const Icon(Icons.error, size: 60),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pokemonNumber(pokemon.pokemonId.toString().padLeft(3, '0')),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (pokemon.types != null && pokemon.types!.isNotEmpty) ...<Widget>[
            SectionTitle(l10n.detailTypes),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pokemon.types!
                  .map(
                    (PokemonType type) =>
                        PokemonTypeChip.large(type: type.type.name),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          if (pokemon.height != null)
            LabelledValueRow(
              label: l10n.detailHeight,
              value: l10n.valueMeters(pokemon.height! / 10),
            ),
          if (pokemon.weight != null)
            LabelledValueRow(
              label: l10n.detailWeight,
              value: l10n.valueKilograms(pokemon.weight! / 10),
            ),
          if (pokemon.baseExperience != null)
            LabelledValueRow(
              label: l10n.detailBaseExperience,
              value: '${pokemon.baseExperience}',
            ),

          if (pokemon.abilities != null &&
              pokemon.abilities!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            SectionTitle(l10n.detailAbilities),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pokemon.abilities!
                  .map(
                    (PokemonAbility a) => AbilityChip(
                      name: a.ability.name,
                      isHidden: a.isHidden,
                      hiddenLabel: l10n.detailAbilityHidden,
                    ),
                  )
                  .toList(),
            ),
          ],

          if (pokemon.stats != null && pokemon.stats!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            SectionTitle(l10n.detailStats),
            const SizedBox(height: 8),
            ...pokemon.stats!.map(
              (PokemonStat s) => StatBar(
                label: _statLabel(s.stat.name, l10n),
                value: s.baseStat,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// The API returns stat keys like `special-attack`; map them onto localized
  /// labels and fall back to the raw key for anything new.
  String _statLabel(String apiName, AppLocalizations l10n) {
    return switch (apiName) {
      'hp' => l10n.statHp,
      'attack' => l10n.statAttack,
      'defense' => l10n.statDefense,
      'special-attack' => l10n.statSpecialAttack,
      'special-defense' => l10n.statSpecialDefense,
      'speed' => l10n.statSpeed,
      _ => apiName,
    };
  }
}
