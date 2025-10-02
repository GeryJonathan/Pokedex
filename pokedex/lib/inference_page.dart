import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'inference_result.dart';
import 'capture_animation.dart'; // <-- Import the new animation file

class InferencePage extends StatefulWidget {
  final String imagePath;
  const InferencePage({super.key, required this.imagePath});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  String? _predictionLabel;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCaptureAndInference();
  }

  // New method to run inference and animation in parallel
  Future<void> _startCaptureAndInference() async {
    try {
      // Define the fixed duration for our animation
      Future<void> animationFuture = Future.delayed(const Duration(milliseconds: 5000));
      
      // Run the ML model
      Future<String> inferenceFuture = runInference();

      // Wait for both the animation AND the inference to complete
      var results = await Future.wait([animationFuture, inferenceFuture]);

      // Once both are done, navigate to the result page
      final prediction = results[1] as String;
      if (mounted) {
        navigateToInferenceResultPage(prediction);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to run inference. Please try a different image.\n\nError: ${e.toString()}";
        });
      }
    }
  }

  // Modified to return the label instead of setting state
  Future<String> runInference() async {
    Interpreter interpreter = await Interpreter.fromAsset('assets/pokemon-classifier.tflite');
    List<String> labels = await _loadLabels();

    var inputTensor = _preprocessImage(File(widget.imagePath));
    var outputShape = interpreter.getOutputTensor(0).shape;
    var outputBuffer = List.generate(outputShape[0], (i) => List.filled(outputShape[1], 0.0));
    
    interpreter.run(inputTensor, outputBuffer);
    
    List<double> prediction = outputBuffer[0];
    String predictionLabel = getPredictionLabel(prediction, labels);
    
    interpreter.close();
    return predictionLabel;
  }

  Future<List<String>> _loadLabels() async {
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    return labelsData.split('\n').map((label) => label.trim()).toList();
  }
  
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    // This logic remains the same
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Could not decode image.");

    final resizedImage = img.copyResize(image, width: 150, height: 150);
    var inputTensor = List.generate(1, (i) => List.generate(150, (j) => List.generate(150, (k) => List.generate(3, (l) => 0.0))));
    
    for (var y = 0; y < 150; y++) {
      for (var x = 0; x < 150; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputTensor[0][y][x][0] = pixel.r / 255.0;
        inputTensor[0][y][x][1] = pixel.g / 255.0;
        inputTensor[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return inputTensor;
  }

  String getPredictionLabel(List<double> prediction, List<String> labels) {
    // This logic remains the same
    double maxScore = 0.0;
    int bestIndex = -1;
    for (int i = 0; i < prediction.length; i++) {
      if (prediction[i] > maxScore) {
        maxScore = prediction[i];
        bestIndex = i;
      }
    }
    if (bestIndex == -1 || bestIndex >= labels.length) return "Unknown";
    return labels[bestIndex];
  }

  void navigateToInferenceResultPage(String predictionLabel) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => InferenceResultPage(
              imagePath: widget.imagePath,
              predictionLabel: predictionLabel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAPTURING...',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 2)),
      ),
      body: Center(
        child: _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontFamily: 'Orbitron'),
                  textAlign: TextAlign.center,
                ),
              )
            // Show the animation instead of a simple loading indicator
            : CaptureAnimation(imagePath: widget.imagePath),
      ),
    );
  }
}