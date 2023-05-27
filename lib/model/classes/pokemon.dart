import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable()
class Pokemon {
  Pokemon({required this.name, required this.url});

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  final String name;
  final String url;

  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}
