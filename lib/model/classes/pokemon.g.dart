// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
  name: json['name'] as String,
  url: json['url'] as String?,
  id: (json['id'] as num?)?.toInt(),
  sprites: json['sprites'] == null
      ? null
      : PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
  types: (json['types'] as List<dynamic>?)
      ?.map((e) => PokemonType.fromJson(e as Map<String, dynamic>))
      .toList(),
  height: (json['height'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toInt(),
  stats: (json['stats'] as List<dynamic>?)
      ?.map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
      .toList(),
  abilities: (json['abilities'] as List<dynamic>?)
      ?.map((e) => PokemonAbility.fromJson(e as Map<String, dynamic>))
      .toList(),
  baseExperience: (json['base_experience'] as num?)?.toInt(),
);

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'id': instance.id,
  'sprites': instance.sprites?.toJson(),
  'types': instance.types?.map((e) => e.toJson()).toList(),
  'height': instance.height,
  'weight': instance.weight,
  'stats': instance.stats?.map((e) => e.toJson()).toList(),
  'abilities': instance.abilities?.map((e) => e.toJson()).toList(),
  'base_experience': instance.baseExperience,
};

PokemonSprites _$PokemonSpritesFromJson(Map<String, dynamic> json) =>
    PokemonSprites(
      frontDefault: json['front_default'] as String?,
      other: json['other'] == null
          ? null
          : OtherSprites.fromJson(json['other'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonSpritesToJson(PokemonSprites instance) =>
    <String, dynamic>{
      'front_default': instance.frontDefault,
      'other': instance.other?.toJson(),
    };

OtherSprites _$OtherSpritesFromJson(Map<String, dynamic> json) => OtherSprites(
  officialArtwork: json['official-artwork'] == null
      ? null
      : OfficialArtwork.fromJson(
          json['official-artwork'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$OtherSpritesToJson(OtherSprites instance) =>
    <String, dynamic>{'official-artwork': instance.officialArtwork?.toJson()};

OfficialArtwork _$OfficialArtworkFromJson(Map<String, dynamic> json) =>
    OfficialArtwork(frontDefault: json['front_default'] as String?);

Map<String, dynamic> _$OfficialArtworkToJson(OfficialArtwork instance) =>
    <String, dynamic>{'front_default': instance.frontDefault};

PokemonType _$PokemonTypeFromJson(Map<String, dynamic> json) => PokemonType(
  slot: (json['slot'] as num).toInt(),
  type: TypeInfo.fromJson(json['type'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PokemonTypeToJson(PokemonType instance) =>
    <String, dynamic>{'slot': instance.slot, 'type': instance.type.toJson()};

TypeInfo _$TypeInfoFromJson(Map<String, dynamic> json) =>
    TypeInfo(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$TypeInfoToJson(TypeInfo instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};

PokemonStat _$PokemonStatFromJson(Map<String, dynamic> json) => PokemonStat(
  baseStat: (json['base_stat'] as num).toInt(),
  stat: StatInfo.fromJson(json['stat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PokemonStatToJson(PokemonStat instance) =>
    <String, dynamic>{
      'base_stat': instance.baseStat,
      'stat': instance.stat.toJson(),
    };

StatInfo _$StatInfoFromJson(Map<String, dynamic> json) =>
    StatInfo(name: json['name'] as String);

Map<String, dynamic> _$StatInfoToJson(StatInfo instance) => <String, dynamic>{
  'name': instance.name,
};

PokemonAbility _$PokemonAbilityFromJson(Map<String, dynamic> json) =>
    PokemonAbility(
      ability: AbilityInfo.fromJson(json['ability'] as Map<String, dynamic>),
      isHidden: json['is_hidden'] as bool,
    );

Map<String, dynamic> _$PokemonAbilityToJson(PokemonAbility instance) =>
    <String, dynamic>{
      'ability': instance.ability.toJson(),
      'is_hidden': instance.isHidden,
    };

AbilityInfo _$AbilityInfoFromJson(Map<String, dynamic> json) =>
    AbilityInfo(name: json['name'] as String);

Map<String, dynamic> _$AbilityInfoToJson(AbilityInfo instance) =>
    <String, dynamic>{'name': instance.name};
