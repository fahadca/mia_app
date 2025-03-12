import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'face_registration.dart';
import 'face_recognition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ Added super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // ✅ Added super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}
