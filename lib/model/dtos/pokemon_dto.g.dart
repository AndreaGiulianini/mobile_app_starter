// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonDTO _$PokemonDTOFromJson(Map<String, dynamic> json) => PokemonDTO(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>).map((e) => Pokemon.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$PokemonDTOToJson(PokemonDTO instance) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
