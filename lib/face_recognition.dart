import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  String recognizedName = "Detecting...";
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
      _startFaceRecognition();
    }
  }

  void _startFaceRecognition() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;
        File? imageFile = await _convertCameraImageToFile(image);
        if (imageFile != null) {
          _processFaceRecognition(imageFile);
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

  Future<void> _processFaceRecognition(File imageFile) async {
    List<Face> faces = await ApiService.detectFaces(imageFile, _faceDetector);
    if (faces.isNotEmpty) {
      String name = await ApiService.recognizeFace(imageFile);
      if (mounted) {
        setState(() {
          recognizedName = name.isNotEmpty ? name : "No match";
        });
      }
      flutterTts.speak(recognizedName);
    } else {
      if (mounted) {
        setState(() {
          recognizedName = "No match";
        });
      }
    }
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
      child: Scaffold(
        appBar: AppBar(title: const Text("Live Face Recognition")),
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
                recognizedName,
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
