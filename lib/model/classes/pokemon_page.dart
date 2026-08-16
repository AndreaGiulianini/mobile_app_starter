import 'package:equatable/equatable.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

/// One page of Pokémon, plus the API's `count` so pagination knows where the
/// collection ends.
final class PokemonPage extends Equatable {
  const PokemonPage({required this.items, required this.total});

  final List<Pokemon> items;
  final int total;

  @override
  List<Object?> get props => <Object?>[items, total];
}
