import 'package:flutter/material.dart';
// import 'splash_screen.dart';
import 'main_page.dart';
import 'package:tflite/tflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Tflite.loadModel(
    model: "assets/pokemon-classifier.tflite",
    labels: "assets/labels.txt",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        '/main': (context) => MainPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadModel().then((_) {
      _navigateToMainPage();
    });
  }

  Future<void> _loadModel() async {
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

  _navigateToMainPage() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Pokemon Classifier',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
