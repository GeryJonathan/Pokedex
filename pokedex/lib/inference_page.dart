import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'inference_result.dart'; // Import the InferenceResultPage

class InferencePage extends StatefulWidget {
  final String imagePath;

  const InferencePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _InferencePageState createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  late Interpreter _interpreter;
  List<String>? _labels;
  TensorImage? _inputImage;
  TensorBuffer? _outputBuffer;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      print('Loading model...');
      _interpreter = await Interpreter.fromAsset('pokemon-classifier.tflite');
      print('Model loaded successfully');

      print('Loading labels...');
      _labels = await FileUtil.loadLabels('assets/labels.txt');
      if (_labels == null || _labels!.isEmpty) {
        throw Exception('Labels not loaded');
      }
      print('Labels loaded successfully');

      print('Loading and preprocessing image...');
      _inputImage = TensorImage.fromFile(File(widget.imagePath));
      _inputImage = ImageProcessorBuilder()
          .add(ResizeOp(150, 150, ResizeMethod.BILINEAR))
          .add(CastOp(TfLiteType.float32))
          .add(NormalizeOp(0, 1)) // Normalize image to [0, 1]
          .build()
          .process(_inputImage!);

      print('Image loaded and preprocessed successfully');

      var outputShape = _interpreter.getOutputTensor(0).shape;
      _outputBuffer =
          TensorBuffer.createFixedSize(outputShape, TfLiteType.float32);
      print(_outputBuffer?.getShape());

      print('Running inference...');
      _interpreter.run(_inputImage!.buffer, _outputBuffer!.buffer);
      print('Inference run successfully');

      // Print the raw output buffer values for debugging
      print('Output buffer values: ${_outputBuffer!.getDoubleList()}');

      setState(() {});
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  void navigateToInferenceResultPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InferenceResultPage(
              imagePath: widget.imagePath,
              predictionLabel: getPredictionLabel())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inference Result')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(widget.imagePath)),
              SizedBox(height: 16),
              _outputBuffer != null && _labels != null
                  ? ElevatedButton(
                      onPressed: navigateToInferenceResultPage,
                      child: Text('Show Result'),
                    )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String getPredictionLabel() {
    var outputList = _outputBuffer!.getDoubleList();
    print('Processed output buffer values: $outputList');

    // Process the output buffer in chunks
    int chunkSize = 30; // Adjust chunk size as needed
    double maxVal = double.negativeInfinity;
    int maxIndex = -1;

    for (int i = 0; i < outputList.length; i += chunkSize) {
      int end = (i + chunkSize < outputList.length) ? i + chunkSize : outputList.length;
      List<double> chunk = outputList.sublist(i, end);

      for (int j = 0; j < chunk.length; j++) {
        if (chunk[j] > maxVal) {
          maxVal = chunk[j];
          maxIndex = i + j; // Adjusting index to the original list index
        }
      }
    }

    if (maxIndex == -1) {
      throw Exception('Failed to find max value in output buffer');
    }

    print('Max value: $maxVal at index: $maxIndex');
    print('Predicted label: ${_labels![maxIndex]}');

    return _labels![maxIndex];
  }
}
