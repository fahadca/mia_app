import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.7:5000";

  /// Pick an image from the camera for face registration.
  static Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Detect faces in the given image using ML Kit.
  static Future<List<Face>> detectFaces(
    File image,
    FaceDetector faceDetector,
  ) async {
    final inputImage = InputImage.fromFile(image);
    return await faceDetector.processImage(inputImage);
  }

  /// Send an image to Flask API for face registration.
  static Future<bool> registerFace(File image, String name) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register_face'),
      );
      request.fields['name'] = name;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send a frame to Flask API for real-time face recognition.
  static Future<String> recognizeFace(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recognize_face'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      return response.statusCode == 200
          ? await response.stream.bytesToString()
          : "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }
}
