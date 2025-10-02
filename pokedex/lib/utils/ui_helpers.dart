import 'package:flutter/material.dart';

// Helper to get a color based on Pokémon type
Color getTypeColor(String type) {
  switch (type) {
    case 'grass': return Colors.green.shade400;
    case 'fire': return Colors.red.shade400;
    case 'water': return Colors.blue.shade400;
    case 'poison': return Colors.purple.shade400;
    case 'electric': return Colors.yellow.shade700;
    case 'rock': return Colors.brown.shade400;
    case 'ground': return Colors.brown.shade600;
    case 'bug': return Colors.lightGreen.shade500;
    case 'psychic': return Colors.pink.shade400;
    case 'fighting': return Colors.orange.shade800;
    case 'ghost': return Colors.deepPurple.shade400;
    case 'ice': return Colors.cyan.shade200;
    case 'dragon': return Colors.indigo.shade500;
    case 'fairy': return Colors.pink.shade200;
    case 'dark': return Colors.blueGrey.shade800;
    case 'steel': return Colors.grey.shade500;
    case 'flying': return Colors.lightBlue.shade300;
    default: return Colors.grey;
  }
}