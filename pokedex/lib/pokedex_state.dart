import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokedexState extends ChangeNotifier {
  late SharedPreferences _prefs;
  final Set<String> _capturedPokemon = {};

  // Getter to allow other widgets to see the captured list
  Set<String> get capturedPokemon => _capturedPokemon;

  PokedexState() {
    _loadCapturedPokemon();
  }

  // Load the list of captured Pokémon from the device's storage
  Future<void> _loadCapturedPokemon() async {
    _prefs = await SharedPreferences.getInstance();
    final capturedList = _prefs.getStringList('capturedPokemon') ?? [];
    _capturedPokemon.addAll(capturedList);
    notifyListeners();
  }

  // Check if a specific Pokémon has been captured
  bool isCaptured(String pokemonName) {
    return _capturedPokemon.contains(pokemonName.toLowerCase());
  }

  // Add a new Pokémon to the captured list and save it
  Future<void> addCapture(String pokemonName) async {
    _capturedPokemon.add(pokemonName.toLowerCase());
    await _prefs.setStringList('capturedPokemon', _capturedPokemon.toList());
    notifyListeners(); // This tells the UI to update
  }
}