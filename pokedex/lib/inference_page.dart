import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

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
          .add(ResizeOp(150, 150, ResizeMethod.NEAREST_NEIGHBOUR))
          .add(NormalizeOp(0, 1)) // Normalize image to [0, 1]
          .add(CastOp(TfLiteType.float32))
          .build()
          .process(_inputImage!);
          print(_inputImage!.dataType);
      print('Image loaded and preprocessed successfully');

      var outputShape = _interpreter.getOutputTensor(0).shape;
      _outputBuffer = TensorBuffer.createFixedSize(outputShape, TfLiteType.float32);

      print('Running inference...');
      _interpreter.run(_inputImage!.buffer, _outputBuffer!.buffer);
      print('Inference run successfully');

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
                  ? Text('Prediction: ${getPredictionLabel()}')
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String getPredictionLabel() {
    var outputList = _outputBuffer!.getDoubleList(); // Correct method name
    var maxIndex = outputList.indexOf(outputList.reduce((curr, next) => curr > next ? curr : next));
    return _labels![maxIndex];
  }
}
