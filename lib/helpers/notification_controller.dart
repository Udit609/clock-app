import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/alarm_info.dart';
import 'alarm_helper.dart';

class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'Stop') {
      int notificationId = receivedAction.id!;
      await _updateAlarmPendingStatus(notificationId, false);
    }
  }
  /// This method updates the values in the database for a alarm when a button is pressed in the notification
  static Future<void> _updateAlarmPendingStatus(int notificationId, bool isPending) async {
    AlarmHelper alarmHelper = AlarmHelper();
    List<AlarmInfo> alarms = await alarmHelper.getAlarms();

    for (AlarmInfo alarm in alarms) {
      print(alarm.notificationId);
      print('received ID : $notificationId');
      // Map<int, int> selectedDaysMap = alarm.getSelectedDaysMap();
      if ( alarm.notificationId == notificationId) {
        alarm.isPending = isPending;
        await alarmHelper.updateAlarm(alarm);
        break;
      }
    }
  }
}