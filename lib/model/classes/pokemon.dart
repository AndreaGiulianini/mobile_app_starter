import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable(explicitToJson: true)
class Pokemon {
  Pokemon({required this.name, this.url, this.id, this.sprites, this.types, this.height, this.weight});

  factory Pokemon.fromJson(Map<String, dynamic> json) => _$PokemonFromJson(json);

  final String name;
  final String? url;
  final int? id;
  final PokemonSprites? sprites;
  final List<PokemonType>? types;
  final int? height;
  final int? weight;

  Map<String, dynamic> toJson() => _$PokemonToJson(this);

  // Extract Pokemon ID from URL (e.g., "https://pokeapi.co/api/v2/pokemon/25/" -> 25)
  int get pokemonId {
    if (id != null) {
      return id!;
    }
    if (url != null) {
      final RegExp regex = RegExp(r'/pokemon/(\d+)');
      final Match? match = regex.firstMatch(url!);
      return match != null ? int.parse(match.group(1)!) : 0;
    }
    return 0;
  }
}

@JsonSerializable()
class PokemonSprites {
  PokemonSprites({this.frontDefault, this.other});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) => _$PokemonSpritesFromJson(json);

  @JsonKey(name: 'front_default')
  final String? frontDefault;
  final OtherSprites? other;

  Map<String, dynamic> toJson() => _$PokemonSpritesToJson(this);
}

@JsonSerializable()
class OtherSprites {
  OtherSprites({this.officialArtwork});

  factory OtherSprites.fromJson(Map<String, dynamic> json) => _$OtherSpritesFromJson(json);

  @JsonKey(name: 'official-artwork')
  final OfficialArtwork? officialArtwork;

  Map<String, dynamic> toJson() => _$OtherSpritesToJson(this);
}

@JsonSerializable()
class OfficialArtwork {
  OfficialArtwork({this.frontDefault});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) => _$OfficialArtworkFromJson(json);

  @JsonKey(name: 'front_default')
  final String? frontDefault;

  Map<String, dynamic> toJson() => _$OfficialArtworkToJson(this);
}

@JsonSerializable()
class PokemonType {
  PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) => _$PokemonTypeFromJson(json);

  final int slot;
  final TypeInfo type;

  Map<String, dynamic> toJson() => _$PokemonTypeToJson(this);
}

@JsonSerializable()
class TypeInfo {
  TypeInfo({required this.name, required this.url});

  factory TypeInfo.fromJson(Map<String, dynamic> json) => _$TypeInfoFromJson(json);

  final String name;
  final String url;

  Map<String, dynamic> toJson() => _$TypeInfoToJson(this);
}
