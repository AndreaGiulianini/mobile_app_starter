import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

/// What [Pokemon.pokemonId] returns when there is neither an `id` field nor a
/// parsable id in `url`. Callers must skip these rather than request `/0`.
const int kUnknownPokemonId = 0;

// Equatable throughout: these objects sit inside state `props`, and without
// value equality two identical states never compare equal, so every emit
// rebuilt the whole grid. explicit_to_json comes from build.yaml, globally.
@JsonSerializable()
class Pokemon extends Equatable {
  const Pokemon({
    required this.name,
    this.url,
    this.id,
    this.sprites,
    this.types,
    this.height,
    this.weight,
    this.stats,
    this.abilities,
    this.baseExperience,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  final String name;
  final String? url;
  final int? id;
  final PokemonSprites? sprites;
  final List<PokemonType>? types;
  final int? height;
  final int? weight;
  final List<PokemonStat>? stats;
  final List<PokemonAbility>? abilities;

  @JsonKey(name: 'base_experience')
  final int? baseExperience;

  Map<String, dynamic> toJson() => _$PokemonToJson(this);

  // Static: this getter runs per grid item during scroll, and compiling a
  // RegExp per access is pure waste.
  static final RegExp _idFromUrl = RegExp(r'/pokemon/(\d+)');

  /// The detail payload carries `id`; the list payload carries only a `url`
  /// to parse it out of. Returns [kUnknownPokemonId] when neither works.
  int get pokemonId {
    if (id != null) {
      return id!;
    }
    if (url != null) {
      final Match? match = _idFromUrl.firstMatch(url!);
      return match != null ? int.parse(match.group(1)!) : kUnknownPokemonId;
    }
    return kUnknownPokemonId;
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    url,
    id,
    sprites,
    types,
    height,
    weight,
    stats,
    abilities,
    baseExperience,
  ];
}

@JsonSerializable()
class PokemonSprites extends Equatable {
  const PokemonSprites({this.frontDefault, this.other});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) =>
      _$PokemonSpritesFromJson(json);

  @JsonKey(name: 'front_default')
  final String? frontDefault;
  final OtherSprites? other;

  Map<String, dynamic> toJson() => _$PokemonSpritesToJson(this);

  @override
  List<Object?> get props => <Object?>[frontDefault, other];
}

@JsonSerializable()
class OtherSprites extends Equatable {
  const OtherSprites({this.officialArtwork});

  factory OtherSprites.fromJson(Map<String, dynamic> json) =>
      _$OtherSpritesFromJson(json);

  @JsonKey(name: 'official-artwork')
  final OfficialArtwork? officialArtwork;

  Map<String, dynamic> toJson() => _$OtherSpritesToJson(this);

  @override
  List<Object?> get props => <Object?>[officialArtwork];
}

@JsonSerializable()
class OfficialArtwork extends Equatable {
  const OfficialArtwork({this.frontDefault});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) =>
      _$OfficialArtworkFromJson(json);

  @JsonKey(name: 'front_default')
  final String? frontDefault;

  Map<String, dynamic> toJson() => _$OfficialArtworkToJson(this);

  @override
  List<Object?> get props => <Object?>[frontDefault];
}

@JsonSerializable()
class PokemonType extends Equatable {
  const PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeFromJson(json);

  final int slot;
  final TypeInfo type;

  Map<String, dynamic> toJson() => _$PokemonTypeToJson(this);

  @override
  List<Object?> get props => <Object?>[slot, type];
}

@JsonSerializable()
class TypeInfo extends Equatable {
  const TypeInfo({required this.name, required this.url});

  factory TypeInfo.fromJson(Map<String, dynamic> json) =>
      _$TypeInfoFromJson(json);

  final String name;
  final String url;

  Map<String, dynamic> toJson() => _$TypeInfoToJson(this);

  @override
  List<Object?> get props => <Object?>[name, url];
}

@JsonSerializable()
class PokemonStat extends Equatable {
  const PokemonStat({required this.baseStat, required this.stat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) =>
      _$PokemonStatFromJson(json);

  @JsonKey(name: 'base_stat')
  final int baseStat;
  final StatInfo stat;

  Map<String, dynamic> toJson() => _$PokemonStatToJson(this);

  @override
  List<Object?> get props => <Object?>[baseStat, stat];
}

@JsonSerializable()
class StatInfo extends Equatable {
  const StatInfo({required this.name});

  factory StatInfo.fromJson(Map<String, dynamic> json) =>
      _$StatInfoFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$StatInfoToJson(this);

  @override
  List<Object?> get props => <Object?>[name];
}

@JsonSerializable()
class PokemonAbility extends Equatable {
  const PokemonAbility({required this.ability, required this.isHidden});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) =>
      _$PokemonAbilityFromJson(json);

  final AbilityInfo ability;

  @JsonKey(name: 'is_hidden')
  final bool isHidden;

  Map<String, dynamic> toJson() => _$PokemonAbilityToJson(this);

  @override
  List<Object?> get props => <Object?>[ability, isHidden];
}

@JsonSerializable()
class AbilityInfo extends Equatable {
  const AbilityInfo({required this.name});

  factory AbilityInfo.fromJson(Map<String, dynamic> json) =>
      _$AbilityInfoFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$AbilityInfoToJson(this);

  @override
  List<Object?> get props => <Object?>[name];
}
