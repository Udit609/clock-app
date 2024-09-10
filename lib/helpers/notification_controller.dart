import 'package:alarm_clock/Screens/fullscreen_notification.dart';
import 'package:alarm_clock/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alarm_info.dart';
import '../utils/screen_lock_checker.dart';
import 'alarm_helper.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    const platform = MethodChannel('com.example.alarm_clock/trigger_broadcast');
    await platform.invokeMethod('triggerBroadcast');
    bool? isLocked = await ScreenLockChecker.isLockScreen();
    if (isLocked!) {
      MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => FullscreenNotification(
            title: receivedNotification.title ?? 'Alarm',
            dateTime: DateTime.now(),
            notificationId: receivedNotification.id ?? 0,
          ),
        ),
        (route) => route.isFirst,
      );
      print("Screen off");
    } else {
      print("screen on");
    }
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    int notificationId = receivedAction.id!;
    await updateAlarmPendingStatus(notificationId, false);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'Stop') {
      int notificationId = receivedAction.id!;
      await updateAlarmPendingStatus(notificationId, false);
    }
  }

  /// This method updates the values in the database for a alarm when a button is pressed in the notification
  static Future<void> updateAlarmPendingStatus(
      int notificationId, bool isPending) async {
    AlarmHelper alarmHelper = AlarmHelper();
    List<AlarmInfo> alarms = await alarmHelper.getAlarms();

    for (AlarmInfo alarm in alarms) {
      print(alarm.notificationId);
      print('received ID : $notificationId');
      // Map<int, int> selectedDaysMap = alarm.getSelectedDaysMap();
      if (alarm.notificationId == notificationId) {
        alarm.isPending = isPending;
        await alarmHelper.updateAlarm(alarm);
        break;
      }
    }
  }
}
