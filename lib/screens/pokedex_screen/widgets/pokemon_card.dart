import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, super.key});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        pokemon.sprites?.other?.officialArtwork?.frontDefault ?? pokemon.sprites?.frontDefault ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Pokemon Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (BuildContext context, String url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (BuildContext context, String url, Object error) =>
                            const Icon(Icons.error, size: 50, color: Colors.red),
                      )
                    : const Icon(Icons.catching_pokemon, size: 50, color: Colors.grey),
              ),
            ),
          ),

          // Pokemon Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Pokemon ID and Name
                  Text(
                    '#${pokemon.pokemonId.toString().padLeft(3, '0')}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _capitalize(pokemon.name),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Pokemon Types
                  if (pokemon.types != null && pokemon.types!.isNotEmpty)
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: pokemon.types!.map((PokemonType type) => _buildTypeChip(type.type.name)).toList(),
                      ),
                    ),

                  const Spacer(),

                  // Pokemon Stats (Height & Weight)
                  if (pokemon.height != null && pokemon.weight != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildStat('H: ${pokemon.height! / 10}m'),
                        _buildStat('W: ${pokemon.weight! / 10}kg'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getTypeColor(type), borderRadius: BorderRadius.circular(12)),
      child: Text(
        _capitalize(type),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStat(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return Colors.grey;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow[700]!;
      case 'grass':
        return Colors.green;
      case 'ice':
        return Colors.lightBlue;
      case 'fighting':
        return Colors.orange[900]!;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo[200]!;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen[700]!;
      case 'rock':
        return Colors.grey[700]!;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo[700]!;
      case 'dark':
        return Colors.brown[800]!;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }
}
