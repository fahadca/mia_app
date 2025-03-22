// import 'dart:async';
// import 'dart:math';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:audioplayers/audioplayers.dart';

// class FallDetection {
//   final Function(bool) onFallDetected;
//   FallDetection({required this.onFallDetected});

//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
//   StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

//   final double _impactThreshold = 18.0; // Lowered for quicker impact detection
//   final double _freeFallThreshold = 4.5; // Detects free fall instantly
//   final double _rotationThreshold = 3.0; // Detects sudden rotation
//   final double _inactivityThreshold = 8.0; // Faster stillness detection
//   final Duration _fallTimeout = const Duration(
//     milliseconds: 800,
//   ); // Extremely fast confirmation
//   final Duration _stillnessCheckDuration = const Duration(
//     seconds: 1,
//   ); // Reduced stillness check delay

//   bool _fallDetected = false;
//   bool _isInFreeFall = false;
//   bool _impactOccurred = false;
//   bool _isStill = false;
//   bool _highRotation = false;
//   DateTime? _fallStartTime;
//   AccelerometerEvent? _lastAccelEvent;
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   void startMonitoring() {
//     _accelerometerSubscription = accelerometerEvents.listen(
//       (event) {
//         double acceleration = _calculateAcceleration(event);

//         // Immediate Free Fall Detection
//         if (acceleration < _freeFallThreshold) {
//           _isInFreeFall = true;
//           _fallStartTime = DateTime.now();
//         }

//         // Faster Impact Detection
//         if (_isInFreeFall &&
//             acceleration > _impactThreshold &&
//             _fallStartTime != null) {
//           if (DateTime.now().difference(_fallStartTime!) <= _fallTimeout) {
//             _isInFreeFall = false;
//             _impactOccurred = true;
//             _fallStartTime = null;
//             _checkPostFallStillness();
//           }
//         }

//         _lastAccelEvent = event;
//       },
//       onError: (error) {
//         print("Accelerometer Error: $error");
//       },
//     );

//     _gyroscopeSubscription = gyroscopeEvents.listen(
//       (event) {
//         double rotation = _calculateRotation(event);

//         // Real-Time High Rotation Detection
//         if (rotation > _rotationThreshold) {
//           _highRotation = true;
//         }
//       },
//       onError: (error) {
//         print("Gyroscope Error: $error");
//       },
//     );
//   }

//   void _checkPostFallStillness() {
//     Future.delayed(_stillnessCheckDuration, () {
//       double stillnessAcceleration =
//           _lastAccelEvent != null
//               ? _calculateAcceleration(_lastAccelEvent!)
//               : 0.0;

//       if (stillnessAcceleration < _inactivityThreshold) {
//         _isStill = true;
//       }

//       // Instant Fall Confirmation
//       if (_impactOccurred && (_isStill || _highRotation)) {
//         _confirmFall();
//       } else {
//         _resetFallDetection();
//       }
//     });
//   }

//   void _confirmFall() async {
//     if (!_fallDetected) {
//       _fallDetected = true;
//       onFallDetected(true);
//       _playEmergencyBeep();

//       Future.delayed(const Duration(seconds: 2), () {
//         _resetFallDetection();
//       });
//     }
//   }

//   void _resetFallDetection() {
//     _fallDetected = false;
//     _impactOccurred = false;
//     _isStill = false;
//     _highRotation = false;
//     onFallDetected(false);
//   }

//   void _playEmergencyBeep() async {
//     try {
//       await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
//       Future.delayed(const Duration(seconds: 2), () {
//         _audioPlayer.stop();
//       });
//     } catch (e) {
//       print("Error playing beep sound: $e");
//     }
//   }

//   double _calculateAcceleration(AccelerometerEvent event) {
//     return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
//   }

//   double _calculateRotation(GyroscopeEvent event) {
//     return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
//   }

//   void stopMonitoring() {
//     _accelerometerSubscription?.cancel();
//     _gyroscopeSubscription?.cancel();
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class FallDetection {
  final Function(bool) onFallDetected;
  FallDetection({required this.onFallDetected});

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  final double _impactThreshold = 20.0; // Higher to ignore minor impacts
  final double _freeFallThreshold = 6.0; // Avoids false free falls from walking
  final double _rotationThreshold =
      3.5; // Ensures high rotation before confirming
  final double _shakeThreshold = 25.0; // Detects only strong hand shakes
  final double _inactivityThreshold = 9.0; // Faster stillness detection
  final Duration _fallTimeout = const Duration(milliseconds: 800);
  final Duration _stillnessCheckDuration = const Duration(seconds: 1);

  bool _fallDetected = false;
  bool _isInFreeFall = false;
  bool _impactOccurred = false;
  bool _isStill = false;
  bool _highRotation = false;
  bool _strongShake = false;
  DateTime? _fallStartTime;
  AccelerometerEvent? _lastAccelEvent;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startMonitoring() {
    _accelerometerSubscription = accelerometerEvents.listen(
      (event) {
        double acceleration = _calculateAcceleration(event);

        // **Shake Detection** (Prevents false falls from slight movement)
        if (acceleration > _shakeThreshold) {
          print("Strong shake detected");
          _strongShake = true;
        }

        // **Free Fall Detection**
        if (acceleration < _freeFallThreshold && _strongShake) {
          print("Free fall detected");
          _isInFreeFall = true;
          _fallStartTime = DateTime.now();
        }

        // **Impact Detection**
        if (_isInFreeFall &&
            acceleration > _impactThreshold &&
            _fallStartTime != null) {
          if (DateTime.now().difference(_fallStartTime!) <= _fallTimeout) {
            print("Impact detected");
            _isInFreeFall = false;
            _impactOccurred = true;
            _fallStartTime = null;
            _checkPostFallStillness();
          }
        }

        _lastAccelEvent = event;
      },
      onError: (error) {
        print("Accelerometer Error: $error");
      },
    );

    _gyroscopeSubscription = gyroscopeEvents.listen(
      (event) {
        double rotation = _calculateRotation(event);

        // **Rotation Detection** (Helps detect only actual falls)
        if (rotation > _rotationThreshold) {
          print("High rotation detected");
          _highRotation = true;
        }
      },
      onError: (error) {
        print("Gyroscope Error: $error");
      },
    );
  }

  void _checkPostFallStillness() {
    Future.delayed(_stillnessCheckDuration, () {
      double stillnessAcceleration =
          _lastAccelEvent != null
              ? _calculateAcceleration(_lastAccelEvent!)
              : 0.0;

      if (stillnessAcceleration < _inactivityThreshold) {
        print("Stillness detected");
        _isStill = true;
      }

      // **Final Fall Confirmation**
      if (_impactOccurred && (_isStill || _highRotation)) {
        _confirmFall();
      } else {
        print("Fall detection failed. Resetting...");
        _resetFallDetection();
      }
    });
  }

  void _confirmFall() async {
    if (!_fallDetected) {
      print("Fall confirmed!");
      _fallDetected = true;
      onFallDetected(true);
      _playEmergencyBeep();

      Future.delayed(const Duration(seconds: 2), () {
        _resetFallDetection();
      });
    }
  }

  void _resetFallDetection() {
    print("Fall detection reset.");
    _fallDetected = false;
    _impactOccurred = false;
    _isStill = false;
    _highRotation = false;
    _strongShake = false;
    onFallDetected(false);
  }

  void _playEmergencyBeep() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      Future.delayed(const Duration(seconds: 2), () {
        _audioPlayer.stop();
      });
    } catch (e) {
      print("Error playing beep sound: $e");
    }
  }

  double _calculateAcceleration(AccelerometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  double _calculateRotation(GyroscopeEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }
}
