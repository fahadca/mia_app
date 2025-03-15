// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class ApiService {
//   static const String baseUrl = "http://192.168.1.6:5000";

//   static Future<File?> pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.camera,
//     );
//     return pickedFile != null ? File(pickedFile.path) : null;
//   }

//   static Future<List<Face>> detectFaces(
//     File image,
//     FaceDetector faceDetector,
//   ) async {
//     final inputImage = InputImage.fromFile(image);
//     return await faceDetector.processImage(inputImage);
//   }

//   static Future<bool> registerFace(File image, String name) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/register_face'),
//       );
//       request.fields['name'] = name;
//       request.files.add(await http.MultipartFile.fromPath('image', image.path));
//       var response = await request.send();
//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<String> recognizeFace(File image) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/recognize_face'),
//       );
//       request.files.add(await http.MultipartFile.fromPath('image', image.path));
//       var response = await request.send();
//       return response.statusCode == 200
//           ? await response.stream.bytesToString()
//           : "Unknown";
//     } catch (e) {
//       return "Unknown";
//     }
//   }

//   static Future<List<Map<String, String>>> getLastFiveFaces() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/last_five_faces'));
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data
//             .map<Map<String, String>>(
//               (entry) => {
//                 "name": (entry['name'] ?? "Unknown").toString(),
//                 "timestamp": (entry['timestamp'] ?? "Unknown").toString(),
//               },
//             )
//             .toList();
//       }
//     } catch (e) {}
//     return [];
//   }
// }

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.6:5000"; // Ensure correct IP

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
      print("Sending request to: $baseUrl/recognize_face");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recognize_face'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      print("Response: $responseBody");
      return response.statusCode == 200 ? responseBody : "Unknown";
    } catch (e) {
      print("Error in API call: $e");
      return "Unknown";
    }
  }

  static Future<List<Map<String, String>>> getLastFiveFaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/last_five_faces'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map<Map<String, String>>(
              (entry) => {
                "name": (entry['name'] ?? "Unknown").toString(),
                "timestamp": (entry['timestamp'] ?? "Unknown").toString(),
              },
            )
            .toList();
      }
    } catch (e) {
      print("Error fetching last five faces: $e");
    }
    return [];
  }
}
