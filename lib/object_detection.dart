import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  List<String> detectedObjects = [];
  FlutterTts flutterTts = FlutterTts();
  int _tapCounter = 0;
  DateTime? _firstTapTime;

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
      _startObjectDetection();
    }
  }

  void _startObjectDetection() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;
        File? imageFile = await _convertCameraImageToFile(image);
        if (imageFile != null) {
          _processObjectDetection(imageFile);
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

  Future<void> _processObjectDetection(File imageFile) async {
    List<String> objects = await ApiService.detectObjects(imageFile);
    if (mounted) {
      setState(() {
        detectedObjects = objects;
      });
    }
    if (objects.isNotEmpty) {
      flutterTts.speak(objects.join(", "));
    }
  }

  void _handleTripleTap(BuildContext context) {
    if (_firstTapTime == null ||
        DateTime.now().difference(_firstTapTime!) >
            const Duration(seconds: 1)) {
      _firstTapTime = DateTime.now();
      _tapCounter = 1;
    } else {
      _tapCounter++;
      if (_tapCounter == 3) {
        Navigator.pop(context);
        _tapCounter = 0;
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTripleTap(context),
      child: Scaffold(
        appBar: AppBar(title: const Text("Object Detection")),
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
                detectedObjects.isNotEmpty
                    ? detectedObjects.join(", ")
                    : "Detecting objects...",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
