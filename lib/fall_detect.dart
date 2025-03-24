import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'api_service.dart';

class FallDetection {
  final Function(bool) onFallDetected;
  FallDetection({required this.onFallDetected});

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  final double _impactThreshold = 18.0;
  final double _freeFallThreshold = 4.5;
  final double _rotationThreshold = 3.0;
  final double _inactivityThreshold = 8.0;
  final Duration _fallTimeout = const Duration(milliseconds: 800);
  final Duration _stillnessCheckDuration = const Duration(seconds: 1);

  bool _fallDetected = false;
  bool _isInFreeFall = false;
  bool _impactOccurred = false;
  bool _isStill = false;
  bool _highRotation = false;
  DateTime? _fallStartTime;
  AccelerometerEvent? _lastAccelEvent;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startMonitoring() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double acceleration = _calculateAcceleration(event);

      if (acceleration < _freeFallThreshold) {
        _isInFreeFall = true;
        _fallStartTime = DateTime.now();
      }

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
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      double rotation = _calculateRotation(event);
      if (rotation > _rotationThreshold) {
        _highRotation = true;
      }
    });
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
      await ApiService.sendFallAlert();
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
