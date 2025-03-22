// import 'dart:async';
// import 'dart:math';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:audioplayers/audioplayers.dart';

// class FallDetection {
//   final Function(bool) onFallDetected;
//   FallDetection({required this.onFallDetected});

//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
//   StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

//   final double _impactThreshold = 22.0; // Reduced for quicker impact detection
//   final double _freeFallThreshold = 5.5; // Lowered to detect falls faster
//   final double _rotationThreshold = 3.5; // Detects sudden rotation
//   final double _inactivityThreshold = 10.0; // Detects stillness quicker
//   final Duration _fallTimeout = const Duration(
//     milliseconds: 1200,
//   ); // Faster confirmation
//   final Duration _stillnessCheckDuration = const Duration(
//     seconds: 2,
//   ); // Reduced delay

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

//         // Free Fall Detection
//         if (acceleration < _freeFallThreshold) {
//           _isInFreeFall = true;
//           _fallStartTime = DateTime.now();
//         }

//         // Impact Detection
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
//       cancelOnError: false,
//     );

//     _gyroscopeSubscription = gyroscopeEvents.listen(
//       (event) {
//         double rotation = _calculateRotation(event);

//         // High Rotation Detection
//         if (rotation > _rotationThreshold) {
//           _highRotation = true;
//         }
//       },
//       onError: (error) {
//         print("Gyroscope Error: $error");
//       },
//       cancelOnError: false,
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

//       // Confirm Fall
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

//       Future.delayed(const Duration(seconds: 3), () {
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
//       Future.delayed(const Duration(seconds: 3), () {
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

  final double _impactThreshold = 18.0; // Lowered for quicker impact detection
  final double _freeFallThreshold = 4.5; // Detects free fall instantly
  final double _rotationThreshold = 3.0; // Detects sudden rotation
  final double _inactivityThreshold = 8.0; // Faster stillness detection
  final Duration _fallTimeout = const Duration(
    milliseconds: 800,
  ); // Extremely fast confirmation
  final Duration _stillnessCheckDuration = const Duration(
    seconds: 1,
  ); // Reduced stillness check delay

  bool _fallDetected = false;
  bool _isInFreeFall = false;
  bool _impactOccurred = false;
  bool _isStill = false;
  bool _highRotation = false;
  DateTime? _fallStartTime;
  AccelerometerEvent? _lastAccelEvent;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startMonitoring() {
    _accelerometerSubscription = accelerometerEvents.listen(
      (event) {
        double acceleration = _calculateAcceleration(event);

        // Immediate Free Fall Detection
        if (acceleration < _freeFallThreshold) {
          _isInFreeFall = true;
          _fallStartTime = DateTime.now();
        }

        // Faster Impact Detection
        if (_isInFreeFall &&
            acceleration > _impactThreshold &&
            _fallStartTime != null) {
          if (DateTime.now().difference(_fallStartTime!) <= _fallTimeout) {
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

        // Real-Time High Rotation Detection
        if (rotation > _rotationThreshold) {
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
        _isStill = true;
      }

      // Instant Fall Confirmation
      if (_impactOccurred && (_isStill || _highRotation)) {
        _confirmFall();
      } else {
        _resetFallDetection();
      }
    });
  }

  void _confirmFall() async {
    if (!_fallDetected) {
      _fallDetected = true;
      onFallDetected(true);
      _playEmergencyBeep();

      Future.delayed(const Duration(seconds: 2), () {
        _resetFallDetection();
      });
    }
  }

  void _resetFallDetection() {
    _fallDetected = false;
    _impactOccurred = false;
    _isStill = false;
    _highRotation = false;
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
