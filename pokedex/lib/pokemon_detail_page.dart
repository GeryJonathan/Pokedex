import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'utils/string_extensions.dart';
import 'utils/ui_helpers.dart';

class PokemonDetailPage extends StatelessWidget {
  final String pokemonName;

  const PokemonDetailPage({super.key, required this.pokemonName});

  Future<Map<String, dynamic>> fetchData() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${pokemonName.toLowerCase()}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data for $pokemonName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      appBar: AppBar(
        title: Text(pokemonName.capitalize(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Orbitron')),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final String name = data['name'].toString().capitalize();
            final String imageUrl = data['sprites']['other']['official-artwork']['front_default'];
            final List types = data['types'];
            final double height = (data['height'] as int) / 10.0;
            final double weight = (data['weight'] as int) / 10.0;
            final int baseExperience = data['base_experience'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade200,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 250,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(name, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: types.map((typeInfo) {
                          String typeName = typeInfo['type']['name'];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: getTypeColor(typeName),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              typeName.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 40, thickness: 1),
                      _StatRow(icon: FontAwesomeIcons.rulerVertical, label: 'Height', value: '${height.toStringAsFixed(1)} m'),
                      const SizedBox(height: 15),
                      _StatRow(icon: FontAwesomeIcons.weightHanging, label: 'Weight', value: '${weight.toStringAsFixed(1)} kg'),
                      const SizedBox(height: 15),
                      _StatRow(icon: FontAwesomeIcons.star, label: 'Base EXP', value: '$baseExperience'),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 15),
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}