import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

class InferencePage extends StatefulWidget {
  final String imagePath;

  InferencePage({required this.imagePath});

  @override
  _InferencePageState createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  late List _recognitions;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadModel().then((_) {
      _classifyImage(widget.imagePath);
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    setState(() {
      _busy = true;
    });

    try {
      String? res = await Tflite.loadModel(
        model: 'assets/pokemon-classifier.tflite',
        labels: 'assets/labels.txt',
      );
      print('Model loaded: $res');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _classifyImage(String imagePath) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 1,
      );

      setState(() {
        _recognitions = recognitions!;
        _busy = false;
      });
    } catch (e) {
      print('Failed to classify image: $e');
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inference Result'),
      ),
      body: _busy
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Image.file(File(widget.imagePath)),
                SizedBox(height: 16),
                _recognitions != null && _recognitions.isNotEmpty
                    ? Text(
                        'Prediction: ${_recognitions[0]["label"]}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        'No recognition results.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
    );
  }
}
