import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'pokedex_state.dart';
import 'utils/string_extensions.dart';
import 'pokemon_detail_page.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  late Future<List<Map<String, String>>> _pokemonListFuture;

  @override
  void initState() {
    super.initState();
    _pokemonListFuture = _fetchPokemonList();
  }

  // This data-loading function is correct and remains the same.
  Future<List<Map<String, String>>> _fetchPokemonList() async {
    final String jsonString =
        await rootBundle.loadString('assets/pokemon_list.json');
    final data = jsonDecode(jsonString);
    final List results = data['results'];
    final List<Map<String, String>> pokemonList = [];

    for (var pokemon in results) {
      if (pokemon['name'] != null && pokemon['url'] != null) {
        final name = pokemon['name'] as String;
        final id = pokemon['url'].split('/')[6];
        pokemonList.add({'name': name, 'id': id});
      }
    }
    return pokemonList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POKÉDEX',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _pokemonListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Pokémon found.'));
          }

          final pokemonList = snapshot.data!;
          // We return the GridView directly, which is the standard pattern.
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8, // Adjust aspect ratio for better look
            ),
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];
              final String name = pokemon['name']!;
              final int id = int.parse(pokemon['id']!);

              // The Consumer only wraps the grid item for efficiency.
              return Consumer<PokedexState>(
                builder: (context, pokedexState, child) {
                  final isCaptured = pokedexState.isCaptured(name);
                  return PokemonGridItem(
                    name: name,
                    id: id,
                    isCaptured: isCaptured,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PokemonGridItem extends StatelessWidget {
  final String name;
  final int id;
  final bool isCaptured;

  const PokemonGridItem({
    super.key,
    required this.name,
    required this.id,
    required this.isCaptured,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/$id.png';

    return Card(
      clipBehavior:
          Clip.antiAlias, // Important for rounded corners on Stack children
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: isCaptured ? 4 : 1.5,
      child: InkWell(
        onTap: () {
          if (isCaptured) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetailPage(pokemonName: name),
              ),
            );
          }
        },
        child: Stack(
          fit: StackFit.expand, // Make children fill the card
          children: [
            // The Pokémon Image
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 25.0), // Give space for the text below
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isCaptured ? Colors.transparent : Colors.grey,
                  BlendMode.saturation,
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error_outline, color: Colors.red);
                  },
                ),
              ),
            ),
            // The Text Overlay at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: isCaptured
                      ? Colors.black.withOpacity(0.6)
                      : Colors.grey.shade700.withOpacity(0.6),
                ),
                child: Text(
                  isCaptured
                      ? name.capitalize()
                      : '#${id.toString().padLeft(3, '0')}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Orbitron',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
