import 'package:flutter/material.dart';

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({Key? key}) : super(key: key);

  @override
  _EmotionDetectionScreenState createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Detection')),
      body: const Center(
        child: Text(
          'Emotion Detection Feature Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
