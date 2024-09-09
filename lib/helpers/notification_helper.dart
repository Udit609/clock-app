import 'dart:math';
import 'package:alarm_clock/utils/alarm_methods.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm_info.dart';
import 'alarm_helper.dart';

// Future<void> createPlantFoodNotification() async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 100,
//       channelKey: 'basic_channel',
//       title: 'Alarm',
//       body: 'Florist at 123 Main St. has 2 in stock.',
//       notificationLayout: NotificationLayout.Default,
//     ),
//   );
// }

Future<int> generateUniqueNotificationId() async {
  final random = Random();
  int notificationId;
  bool isUnique = false;

  do {
    notificationId = random.nextInt(1000000);
    isUnique = !(await AlarmHelper().notificationIdExists(notificationId));
  } while (!isUnique);

  return notificationId;
}

Future<void> scheduleAlarmNotification(
    int id, DateTime scheduledTime, String title,int weekDay,{bool repeat = false}) async {
  // Variables
  String localTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();
  String day = AlarmMethods.getDayName(DateTime.now().weekday, false);
  String time = DateFormat('HH:mm').format(scheduledTime);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: 'scheduled',
      title: title == 'Label' ? 'Alarm': title,
      body: '$day $time Swipe to stop',
      backgroundColor: CustomColors.clockBG,
      color: Colors.white,
      notificationLayout: NotificationLayout.Default,
      displayOnBackground: true,
      displayOnForeground: true,
      category: NotificationCategory.Alarm,
      wakeUpScreen: true,
      autoDismissible: false,
      fullScreenIntent: true,
      locked: true,
      actionType: ActionType.Default,
      // timeoutAfter: const Duration(minutes: 2),
    ),
    schedule: NotificationCalendar(
      weekday: weekDay,
      hour: scheduledTime.hour,
      minute: scheduledTime.minute,
      second: 0,
      millisecond: 0,
      timeZone: localTimeZone,
      allowWhileIdle: true,
      repeats: repeat,
      preciseAlarm: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'Stop',
        label: 'Stop',
        color: Colors.white,
        actionType: ActionType.Default,
      ),
    ],
  );
}

Future<void> cancelScheduledNotifications(int id) async {
  await AwesomeNotifications().cancel(id);
  print("Notification deleted: $id");
}

Future<void> rescheduleNotificationsForSelectedDays(AlarmInfo alarm) async {
  Map<int, int> selectedDaysMap = alarm.getSelectedDaysMap();

  if (selectedDaysMap.isEmpty) {
    return;
  }

  for (var notificationId in selectedDaysMap.values) {
    await cancelScheduledNotifications(notificationId);
  }

  for (var entry in selectedDaysMap.entries) {
    int dayIndex = entry.key;
    int notificationId = entry.value;

    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.alarmDateTime!.hour,
      alarm.alarmDateTime!.minute,
    );

    await scheduleAlarmNotification(
        notificationId, scheduledTime, alarm.title!, dayIndex,
        repeat: true);
  }
}
