import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key}); // ✅ Added super.key

  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  Future<void> _registerFace() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return; // ✅ Check if mounted before using context
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a name")));
      return;
    }

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

    bool success = await ApiService.registerFace(image, name);
    if (!mounted) return; // ✅ Check if mounted before using context

    String message = success ? "Face Registered!" : "Registration Failed";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _faceDetector.close();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Registration")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Enter Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerFace,
              child: const Text("Register Face"),
            ),
          ],
        ),
      ),
    );
  }
}
