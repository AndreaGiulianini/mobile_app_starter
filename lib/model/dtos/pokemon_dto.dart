import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

part 'pokemon_dto.g.dart';

/// Wire envelope of the paginated list endpoint.
///
/// `next`/`previous` are deliberately not parsed: pagination follows `count`
/// and an explicit offset, so the cursor fields were dead weight.
@JsonSerializable()
class PokemonDTO {
  PokemonDTO({required this.count, required this.results});

  factory PokemonDTO.fromJson(Map<String, dynamic> json) =>
      _$PokemonDTOFromJson(json);

  final int count;
  final List<Pokemon> results;

  Map<String, dynamic> toJson() => _$PokemonDTOToJson(this);
}
