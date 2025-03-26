// import 'package:flutter/material.dart';

// class EmotionDetectionScreen extends StatefulWidget {
//   const EmotionDetectionScreen({Key? key}) : super(key: key);

//   @override
//   _EmotionDetectionScreenState createState() => _EmotionDetectionScreenState();
// }

// class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
//   bool _isLongPress = false; // To detect long press

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () {
//         // When long press is detected, navigate back to the home screen
//         Navigator.pop(
//           context,
//         ); // This will pop the current screen and return to the previous one
//       },
//       onLongPressStart: (_) {
//         setState(() {
//           _isLongPress = true;
//         });
//       },
//       onLongPressEnd: (_) {
//         setState(() {
//           _isLongPress = false;
//         });
//       },
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Emotion Detection')),
//         body: Center(
//           child: Text(
//             _isLongPress
//                 ? 'Long Press Detected! Releasing will go back to Home Screen.'
//                 : 'Emotion Detection Feature Coming Soon!',
//             style: const TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({Key? key}) : super(key: key);

  @override
  _EmotionDetectionScreenState createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  bool _isLongPress = false;
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  String recognizedEmotion = "Detecting...";
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
      _startEmotionRecognition();
    }
  }

  void _startEmotionRecognition() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;
        File? imageFile = await _convertCameraImageToFile(image);
        if (imageFile != null) {
          _processEmotionRecognition(imageFile);
        }
        await Future.delayed(const Duration(seconds: 1));
        _isDetecting = false;
      }
    });
  }

  Future<File?> _convertCameraImageToFile(CameraImage image) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/frame.jpg';
      final XFile? picture = await _cameraController?.takePicture();
      if (picture == null) return null;
      File file = File(path);
      await picture.saveTo(file.path);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> _processEmotionRecognition(File imageFile) async {
    // Using recognizeEmotion instead of recognizeFace
    String emotion = await ApiService.recognizeEmotion(imageFile);
    if (mounted) {
      setState(() {
        recognizedEmotion =
            emotion.isNotEmpty ? emotion : "No emotion detected";
      });
    }
    flutterTts.speak(recognizedEmotion); // Give voice feedback
  }

  void _onLongPress() {
    Navigator.pop(context); // Return to home screen
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onLongPress,
      onLongPressStart: (_) {
        setState(() {
          _isLongPress = true;
        });
      },
      onLongPressEnd: (_) {
        setState(() {
          _isLongPress = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Emotion Detection")),
        body: Column(
          children: [
            Expanded(
              child:
                  _cameraController == null ||
                          !_cameraController!.value.isInitialized
                      ? const Center(child: CircularProgressIndicator())
                      : CameraPreview(_cameraController!),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recognizedEmotion,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
