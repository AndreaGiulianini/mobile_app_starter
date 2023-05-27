import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

part 'pokemon_dto.g.dart';

@JsonSerializable()
class PokemonDTO {
  PokemonDTO({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PokemonDTO.fromJson(Map<String, dynamic> json) =>
      _$PokemonDTOFromJson(json);

  final int count;
  final String next;
  final String? previous;
  final List<Pokemon> results;

  Map<String, dynamic> toJson() => _$PokemonDTOToJson(this);
}
