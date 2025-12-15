import 'package:flutter/material.dart';

/// Pokemon type color mappings for type badges
class PokemonTypeColors {
  PokemonTypeColors._();

  static const Map<String, Color> typeColors = <String, Color>{
    'normal': Colors.grey,
    'fire': Colors.red,
    'water': Colors.blue,
    'electric': Color(0xFFF9A825), // Colors.yellow[700]
    'grass': Colors.green,
    'ice': Colors.lightBlue,
    'fighting': Color(0xFFE65100), // Colors.orange[900]
    'poison': Colors.purple,
    'ground': Colors.brown,
    'flying': Color(0xFF9FA8DA), // Colors.indigo[200]
    'psychic': Colors.pink,
    'bug': Color(0xFF689F38), // Colors.lightGreen[700]
    'rock': Color(0xFF616161), // Colors.grey[700]
    'ghost': Colors.deepPurple,
    'dragon': Color(0xFF303F9F), // Colors.indigo[700]
    'dark': Color(0xFF4E342E), // Colors.brown[800]
    'steel': Colors.blueGrey,
    'fairy': Colors.pinkAccent,
  };

  /// Get the color for a Pokemon type
  /// Returns [fallback] color if type is not found (defaults to grey)
  static Color getTypeColor(String type, [Color fallback = Colors.grey]) {
    return typeColors[type.toLowerCase()] ?? fallback;
  }
}
