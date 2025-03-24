import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fall_detect.dart';
import 'face_registration.dart';
import 'face_recognition.dart';
import 'object_detection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'emotion_detect.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> emergencyContacts = [];
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  late FallDetection _fallDetection;
  bool _fallOccurred = false;
  int _tapCounter = 0;
  DateTime? _firstTapTime;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _fallDetection = FallDetection(
      onFallDetected: (bool detected) {
        setState(() {
          _fallOccurred = detected;
        });
      },
    );
    _fallDetection.startMonitoring();
  }

  @override
  void dispose() {
    _fallDetection.stopMonitoring();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyContacts = prefs.getStringList('emergencyContacts') ?? [];
    });
  }

  void _addEmail() {
    String email = emailController.text.trim();
    if (email.isNotEmpty) {
      FirebaseFirestore.instance.collection('emails').add({'email': email});
      emailController.clear();
    }
  }

  void _deleteEmail(String docId) {
    FirebaseFirestore.instance.collection('emails').doc(docId).delete();
  }

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
        key: scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false, // New
        drawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Emergency Contacts',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                //
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addEmail,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream:
                        FirebaseFirestore.instance
                            .collection('emails')
                            .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView(
                        children:
                            snapshot.data!.docs.map((doc) {
                              return ListTile(
                                title: Text(doc['email']),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteEmail(doc.id),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/781994.jpg', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.teal,
                            size: 30,
                          ),
                          onPressed: () {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        Text(
                          'MIA',
                          style: GoogleFonts.merriweather(
                            color: const Color(0xFF043232),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ).animate().moveY(
                      begin: -39,
                      end: 0,
                      duration: Duration(milliseconds: 1240),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'WELCOME',
                    style: GoogleFonts.alegreya(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Redefining vision, beyond sight',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF14181B),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0x9D115B64),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _fallOccurred ? 'FALL DETECTED' : 'NO FALL',
                          style: GoogleFonts.poppins(
                            color:
                                _fallOccurred
                                    ? Colors.red
                                    : const Color(0xFF39D2C0),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildButton('Register Face', const FaceRegistrationScreen()),
                  _buildButton('Smart Vision', const ObjectDetectionScreen()),
                  _buildButton('Mood Sense', const EmotionDetectionScreen()),
                  _buildButton('Identity Scan', const FaceRecognitionScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Widget? screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: SizedBox(
        width: 250,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2B9990),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          onPressed:
              screen != null
                  ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  )
                  : null,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().scaleXY(
          begin: 0.9,
          end: 1.0,
          duration: Duration(milliseconds: 500),
        ),
      ),
    );
  }
}
