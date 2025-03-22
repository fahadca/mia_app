// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'fall_detect.dart';
// import 'face_registration.dart';
// import 'face_recognition.dart';
// import 'object_detection.dart';

// class HomePageWidget extends StatefulWidget {
//   const HomePageWidget({super.key});

//   @override
//   State<HomePageWidget> createState() => _HomePageWidgetState();
// }

// class _HomePageWidgetState extends State<HomePageWidget> {
//   List<String> emergencyContacts = [];
//   late FallDetection _fallDetection;
//   bool _fallOccurred = false;
//   int _tapCounter = 0;
//   DateTime? _firstTapTime;

//   @override
//   void initState() {
//     super.initState();
//     _loadContacts();
//     _fallDetection = FallDetection(
//       onFallDetected: (bool detected) {
//         setState(() {
//           _fallOccurred = detected;
//         });
//       },
//     );
//     _fallDetection.startMonitoring();
//   }

//   @override
//   void dispose() {
//     _fallDetection.stopMonitoring();
//     super.dispose();
//   }

//   Future<void> _loadContacts() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       emergencyContacts = prefs.getStringList('emergencyContacts') ?? [];
//     });
//   }

//   void _handleTripleTap(BuildContext context) {
//     if (_firstTapTime == null ||
//         DateTime.now().difference(_firstTapTime!) >
//             const Duration(seconds: 1)) {
//       _firstTapTime = DateTime.now();
//       _tapCounter = 1;
//     } else {
//       _tapCounter++;
//       if (_tapCounter == 3) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ObjectDetectionScreen(),
//           ),
//         );
//         _tapCounter = 0;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const FaceRecognitionScreen(),
//           ),
//         );
//       },
//       onTap: () => _handleTripleTap(context),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(title: const Text('MIA')),
//         drawer: Drawer(
//           child: ListView(
//             children: [
//               ListTile(
//                 title: const Text('Register Face'),
//                 onTap:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const FaceRegistrationScreen(),
//                       ),
//                     ),
//               ),
//               ListTile(
//                 title: const Text('Recognize Face'),
//                 onTap:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const FaceRecognitionScreen(),
//                       ),
//                     ),
//               ),
//               ListTile(
//                 title: const Text('Detect Objects'),
//                 onTap:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ObjectDetectionScreen(),
//                       ),
//                     ),
//               ),
//             ],
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _fallOccurred ? 'FALL DETECTED' : 'NO FALL',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: _fallOccurred ? Colors.red : Colors.green,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const FaceRegistrationScreen(),
//                       ),
//                     ),
//                 child: const Text('Register Face'),
//               ),
//               ElevatedButton(
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const FaceRecognitionScreen(),
//                       ),
//                     ),
//                 child: const Text('Recognize Face'),
//               ),
//               ElevatedButton(
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ObjectDetectionScreen(),
//                       ),
//                     ),
//                 child: const Text('Detect Objects'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
