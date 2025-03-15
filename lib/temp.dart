// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'face_registration.dart';
// import 'face_recognition.dart';
// import 'package:flutter/services.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int volumeUpPressCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     HardwareKeyboard.instance.addHandler(_handleKeyEvent);
//   }

//   bool _handleKeyEvent(KeyEvent event) {
//     if (event is KeyDownEvent) {
//       if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
//         _onVolumeUpPressed();
//         return true;
//       }
//     }
//     return false;
//   }

//   void _onVolumeUpPressed() {
//     volumeUpPressCount++;
//     if (volumeUpPressCount == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const FaceRecognitionScreen()),
//       );
//     } else if (volumeUpPressCount == 4) {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   void dispose() {
//     HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('MIA')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FaceRegistrationScreen(),
//                   ),
//                 );
//               },
//               child: const Text('Register Face'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FaceRecognitionScreen(),
//                   ),
//                 );
//               },
//               child: const Text('Recognize Face'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'face_registration.dart';
// import 'face_recognition.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key}); // ✅ Added super.key

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key}); // ✅ Added super.key

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('MIA')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FaceRegistrationScreen(),
//                   ),
//                 );
//               },
//               child: const Text('Register Face'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const FaceRecognitionScreen(),
//                   ),
//                 );
//               },
//               child: const Text('Recognize Face'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




















//





// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'api_service.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';

// class FaceRecognitionScreen extends StatefulWidget {
//   const FaceRecognitionScreen({super.key});

//   @override
//   State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
// }

// class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
//   CameraController? _cameraController;
//   late List<CameraDescription> _cameras;
//   bool _isDetecting = false;
//   String recognizedName = "Detecting...";
//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(enableLandmarks: true),
//   );
//   FlutterTts flutterTts = FlutterTts();
//   int volumeUpPressCount = 0;
//   double previousVolume = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     FlutterVolumeController.addListener((volume) {
//       if (volume > previousVolume) {
//         _onVolumeUpPressed();
//       }
//       previousVolume = volume;
//     });
//   }

//   void _onVolumeUpPressed() {
//     volumeUpPressCount++;
//     if (volumeUpPressCount == 2) {
//       _startFaceRecognition();
//     } else if (volumeUpPressCount == 4) {
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
//     await _cameraController!.initialize();
//     if (mounted) {
//       setState(() {});
//       _startFaceRecognition();
//     }
//   }

//   void _startFaceRecognition() {
//     _cameraController!.startImageStream((CameraImage image) async {
//       if (!_isDetecting) {
//         _isDetecting = true;
//         File? imageFile = await _convertCameraImageToFile(image);
//         if (imageFile != null) {
//           _processFaceRecognition(imageFile);
//         }
//         await Future.delayed(const Duration(seconds: 1)); // Prevent overload
//         _isDetecting = false;
//       }
//     });
//   }

//   Future<File?> _convertCameraImageToFile(CameraImage image) async {
//     try {
//       final directory = await getTemporaryDirectory();
//       final path = '${directory.path}/frame.jpg';
//       final XFile? picture = await _cameraController?.takePicture();
//       if (picture == null) return null;
//       File file = File(path);
//       await picture.saveTo(file.path);
//       return file;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> _processFaceRecognition(File imageFile) async {
//     List<Face> faces = await ApiService.detectFaces(imageFile, _faceDetector);
//     if (faces.isNotEmpty) {
//       String name = await ApiService.recognizeFace(imageFile);
//       if (mounted) {
//         setState(() {
//           recognizedName = name.isNotEmpty ? name : "No match";
//         });
//       }
//       flutterTts.speak(recognizedName);
//     } else {
//       if (mounted) {
//         setState(() {
//           recognizedName = "No match";
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _faceDetector.close();
//     FlutterVolumeController.removeListener();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Live Face Recognition")),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 _cameraController == null ||
//                         !_cameraController!.value.isInitialized
//                     ? const Center(child: CircularProgressIndicator())
//                     : CameraPreview(_cameraController!),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               recognizedName,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }