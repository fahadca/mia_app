import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key}); // ✅ Added super.key

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  Future<void> _recognizeFace() async {
    var image = await ApiService.pickImage();
    if (image == null) return;

    List<Face> faces =
        (await ApiService.detectFaces(
          image,
          _faceDetector,
        )).cast<Face>(); // ✅ Explicit cast

    if (faces.isEmpty) {
      if (!mounted) return; // ✅ Check if mounted before using context
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No face detected")));
      return;
    }

    String name = await ApiService.recognizeFace(image);
    if (!mounted) return; // ✅ Check if mounted before using context

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(name)));
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Recognition")),
      body: Center(
        child: ElevatedButton(
          onPressed: _recognizeFace,
          child: const Text("Recognize Face"),
        ),
      ),
    );
  }
}
