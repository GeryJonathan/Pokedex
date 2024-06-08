import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:http/http.dart' as http;

class InferenceResultPage extends StatelessWidget {
  final String imagePath;
  final String predictionLabel;

  InferenceResultPage({required this.imagePath, required this.predictionLabel});

  Future<Map<String, dynamic>> fetchData(String pokemonName) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchData(predictionLabel.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text('Pokemon Info')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(File(imagePath)),
                  SizedBox(height: 16),
                  Text('Name: ${data['name']}'),
                  Text('Base Experience: ${data['base_experience']}'),
                  Text('Height: ${data['height']} m'),
                  Text('Weight: ${data['weight']} kg'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
