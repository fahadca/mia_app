import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'face_registration.dart';
import 'face_recognition.dart';
import 'object_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tapCounter = 0;
  DateTime? _firstTapTime;

  void _handleTripleTap(BuildContext context) {
    if (_firstTapTime == null ||
        DateTime.now().difference(_firstTapTime!) >
            const Duration(seconds: 1)) {
      _firstTapTime = DateTime.now();
      _tapCounter = 1;
    } else {
      _tapCounter++;
      if (_tapCounter == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ObjectDetectionScreen(),
          ),
        );
        _tapCounter = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FaceRecognitionScreen(),
          ),
        );
      },
      onTap: () => _handleTripleTap(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('MIA')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaceRegistrationScreen(),
                    ),
                  );
                },
                child: const Text('Register Face'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaceRecognitionScreen(),
                    ),
                  );
                },
                child: const Text('Recognize Face'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ObjectDetectionScreen(),
                    ),
                  );
                },
                child: const Text('Detect Objects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
