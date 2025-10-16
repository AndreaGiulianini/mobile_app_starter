// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
  name: json['name'] as String,
  url: json['url'] as String?,
  id: (json['id'] as num?)?.toInt(),
  sprites: json['sprites'] == null ? null : PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
  types: (json['types'] as List<dynamic>?)?.map((e) => PokemonType.fromJson(e as Map<String, dynamic>)).toList(),
  height: (json['height'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toInt(),
);

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'id': instance.id,
  'sprites': instance.sprites?.toJson(),
  'types': instance.types?.map((e) => e.toJson()).toList(),
  'height': instance.height,
  'weight': instance.weight,
};

PokemonSprites _$PokemonSpritesFromJson(Map<String, dynamic> json) => PokemonSprites(
  frontDefault: json['front_default'] as String?,
  other: json['other'] == null ? null : OtherSprites.fromJson(json['other'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PokemonSpritesToJson(PokemonSprites instance) => <String, dynamic>{
  'front_default': instance.frontDefault,
  'other': instance.other,
};

OtherSprites _$OtherSpritesFromJson(Map<String, dynamic> json) => OtherSprites(
  officialArtwork: json['official-artwork'] == null
      ? null
      : OfficialArtwork.fromJson(json['official-artwork'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OtherSpritesToJson(OtherSprites instance) => <String, dynamic>{
  'official-artwork': instance.officialArtwork,
};

OfficialArtwork _$OfficialArtworkFromJson(Map<String, dynamic> json) =>
    OfficialArtwork(frontDefault: json['front_default'] as String?);

Map<String, dynamic> _$OfficialArtworkToJson(OfficialArtwork instance) => <String, dynamic>{
  'front_default': instance.frontDefault,
};

PokemonType _$PokemonTypeFromJson(Map<String, dynamic> json) =>
    PokemonType(slot: (json['slot'] as num).toInt(), type: TypeInfo.fromJson(json['type'] as Map<String, dynamic>));

Map<String, dynamic> _$PokemonTypeToJson(PokemonType instance) => <String, dynamic>{
  'slot': instance.slot,
  'type': instance.type,
};

TypeInfo _$TypeInfoFromJson(Map<String, dynamic> json) =>
    TypeInfo(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$TypeInfoToJson(TypeInfo instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};
