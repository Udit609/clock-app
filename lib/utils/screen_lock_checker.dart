import 'package:flutter/services.dart';

class ScreenLockChecker {
  static const platform = MethodChannel('com.example.alarm_clock/is_screen_locked');

  static Future<bool?> isLockScreen() async {
    try {
      final bool? isLocked = await platform.invokeMethod('isScreenLocked');
      return isLocked;
    } on PlatformException catch (e) {
      print("Failed to check screen lock: '${e.message}'.");
      return null;
    }
  }
}