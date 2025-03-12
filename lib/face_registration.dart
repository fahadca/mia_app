import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:io';
// import 'package:image_picker/image_picker.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _registerFace() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a name")));
      return;
    }

    File? image = await ApiService.pickImage();
    if (image == null) return;

    bool success = await ApiService.registerFace(image, name);
    if (!mounted) return;
    String message = success ? "Face Registered!" : "Registration Failed";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
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
