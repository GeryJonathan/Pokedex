import 'package:flutter/material.dart';
import 'camera_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon Classifier'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open Camera'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()),
            );
          },
        ),
      ),
    );
  }
}
