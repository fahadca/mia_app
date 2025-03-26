import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:location/location.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      "http://192.168.37.181:5000"; // Ensure correct IP

  static Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<List<Face>> detectFaces(
    File image,
    FaceDetector faceDetector,
  ) async {
    final inputImage = InputImage.fromFile(image);
    return await faceDetector.processImage(inputImage);
  }

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

  static Future<String> recognizeFace(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recognize_face'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      return response.statusCode == 200 ? responseBody : "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  static Future<List<String>> detectObjects(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/detect_objects'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      return response.statusCode == 200
          ? List<String>.from(responseBody.split(','))
          : [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendFallAlert() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      double latitude = locationData.latitude ?? 0.0;
      double longitude = locationData.longitude ?? 0.0;

      var response = await http.post(
        Uri.parse('$baseUrl/fall_detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      if (response.statusCode == 200) {
        print("Fall alert sent successfully.");
      } else {
        print("Failed to send fall alert.");
      }
    } catch (e) {
      print("Error sending fall alert: $e");
    }
  }

  // New function to trigger emotion recognition route
  static Future<String> recognizeEmotion(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recognize_emotion'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();

      // Return the emotion detected by the server
      return response.statusCode == 200 ? responseBody : "No Emotion Detected";
    } catch (e) {
      return "Error recognizing emotion: $e";
    }
  }
}
