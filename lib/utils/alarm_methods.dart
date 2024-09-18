import 'package:alarm_clock/helpers/alarm_helper.dart';
import 'package:flutter/material.dart';
import '../helpers/notification_helper.dart';
import '../models/alarm_info.dart';
import 'colors.dart';

class AlarmMethods {
  static String getAlarmStatus(AlarmInfo alarm) {
    if (alarm.isPending == false) {
      return 'Not Scheduled';
    }

    Map<int, int>? selectedDaysMap;
    if (alarm.scheduledDays != null && alarm.scheduledDays!.isNotEmpty) {
      selectedDaysMap = alarm.stringToMap(alarm.scheduledDays!);
    }

    if (alarm.isPending == true &&
        (selectedDaysMap == null || selectedDaysMap.isEmpty)) {
      if (DateTime.now().isBefore(alarm.alarmDateTime!) &&
          DateTime.now().weekday == alarm.alarmDateTime!.weekday) {
        return 'Today';
      }
      return 'Tomorrow';
    }

    if (selectedDaysMap!.length == 1) {
      int dayIndex = selectedDaysMap.keys.first;
      return getDayName(dayIndex, true);
    }

    var sortedKeys = selectedDaysMap.keys.toList()..sort();

    List<String> dayNames =
        sortedKeys.map((dayIndex) => getDayName(dayIndex, false)).toList();
    return dayNames.join(", ");
  }

  static String getDayName(int dayIndex, bool fullName) {
    List<String> fullDayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<String> shortDayNames = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    return fullName ? fullDayNames[dayIndex - 1] : shortDayNames[dayIndex - 1];
  }

  static Future<DateTime?> customTimePicker(
      BuildContext context, DateTime initialDateTime) async {
    final TimeOfDay? time = await showTimePicker(
      hourLabelText: '',
      minuteLabelText: '',
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    return null;
  }

  static Theme timePickerTheme(BuildContext context, Builder child) {
    return Theme(
      data: ThemeData(
        timePickerTheme: TimePickerThemeData(
          backgroundColor: CustomColors.pageBackgroundColor,
          entryModeIconColor: Colors.white,
          helpTextStyle: const TextStyle(fontSize: 15.0, color: Colors.white),
          hourMinuteColor: CustomColors.clockBG,
          hourMinuteTextColor: Colors.white,
          timeSelectorSeparatorColor: WidgetStateProperty.all(Colors.white),
          dialBackgroundColor: CustomColors.clockBG,
          dialHandColor: CustomColors.minHandStatColor,
          dialTextColor: Colors.white,
          dialTextStyle: const TextStyle(
            fontSize: 16.0,
          ),
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      child: child,
    );
  }

  static Future<void> updateTitleDialog(
      BuildContext context, AlarmInfo alarm) async {
    final TextEditingController titleController =
        TextEditingController(text: alarm.title);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.pageBackgroundColor,
          content: Theme(
            data: ThemeData(
                textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionHandleColor: Colors.white,
              selectionColor: Colors.white38,
            )),
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Label',
                labelStyle: const TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
              autofocus: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  alarm.title = newTitle;
                  await AlarmHelper().updateAlarm(alarm);

                  if (alarm.isPending!) {
                    Map<int, int> selectedDaysMap = alarm.getSelectedDaysMap();
                    if (selectedDaysMap.isEmpty) {
                      await cancelScheduledNotifications(alarm.notificationId!);
                      await scheduleAlarmNotification(
                        alarm.notificationId!,
                        alarm.alarmDateTime!,
                        newTitle,
                        alarm.alarmDateTime!.weekday,
                      );
                    } else {
                      await rescheduleNotificationsForSelectedDays(alarm);
                    }
                  }

                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> weekdaySelectionDialog(
      BuildContext context, AlarmInfo alarm) async {
    List<String> daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    Map<int, int> selectedDaysMap = alarm.getSelectedDaysMap();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: CustomColors.pageBackgroundColor,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: daysOfWeek.asMap().entries.map((entry) {
                int index = entry.key + 1;
                String day = entry.value;

                bool isSelected = selectedDaysMap.containsKey(index);

                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        if (isSelected) {
                          selectedDaysMap.remove(index);
                        } else {
                          selectedDaysMap[index] = -1;
                        }
                      });

                      if (!isSelected) {
                        int notificationId =
                            await generateUniqueNotificationId();
                        setState(() {
                          selectedDaysMap[index] = notificationId;
                        });
                      }
                    },
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      margin: const EdgeInsets.only(right: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : CustomColors.clockBG,
                        shape: BoxShape.circle,
                        border: Border.all(color: CustomColors.dividerColor),
                      ),
                      child: Center(
                          child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14.0,
                          color:
                              isSelected ? CustomColors.clockBG : Colors.white,
                        ),
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var savedDaysMap = alarm.getSelectedDaysMap();
                  if (selectedDaysMap.isEmpty) {
                    for (var notificationId in savedDaysMap.values) {
                      await cancelScheduledNotifications(notificationId);
                    }

                    if (alarm.isPending!) {
                      cancelScheduledNotifications(alarm.notificationId ?? 0);
                      alarm.isPending = false;
                    }
                    alarm.scheduledDays = alarm.mapToString(selectedDaysMap);
                  } else {
                    if (savedDaysMap.isNotEmpty) {
                      for (var notificationId in savedDaysMap.values) {
                        await cancelScheduledNotifications(notificationId);
                      }
                    } else {
                      if (alarm.isPending!) {
                        cancelScheduledNotifications(alarm.notificationId ?? 0);
                      }
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
                        notificationId,
                        scheduledTime,
                        alarm.title!,
                        dayIndex,
                        repeat: true,
                      );
                    }

                    alarm.scheduledDays = alarm.mapToString(selectedDaysMap);
                    alarm.isPending = true;

                    DateTime nextAlarmDate =
                        getNextAlarmDate(selectedDaysMap, alarm.alarmDateTime!);
                    String timeDifference = getTimeDifference(nextAlarmDate);
                    showAlarmSnackBar(context, timeDifference);
                  }

                  await AlarmHelper().updateAlarm(alarm);

                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  static DateTime getNextAlarmDate(
      Map<int, int> selectedDaysMap, DateTime newDateTime) {
    DateTime now = DateTime.now();
    DateTime nextAlarmDate = DateTime(
      now.year,
      now.month,
      now.day,
      newDateTime.hour,
      newDateTime.minute,
    );

    List<int> daysOfWeek = selectedDaysMap.keys.toList();
    daysOfWeek.sort();
    int currentDayIndex = now.weekday;

    int nextDayIndex = daysOfWeek.firstWhere(
      (dayIndex) => dayIndex > currentDayIndex,
      orElse: () => daysOfWeek.first,
    );

    if (nextDayIndex < currentDayIndex ||
        (nextDayIndex == currentDayIndex && now.isAfter(nextAlarmDate))) {
      nextAlarmDate = nextAlarmDate
          .add(Duration(days: 7 - (currentDayIndex - nextDayIndex)));
    } else if (nextDayIndex > currentDayIndex) {
      nextAlarmDate =
          nextAlarmDate.add(Duration(days: nextDayIndex - currentDayIndex));
    }
    return nextAlarmDate;
  }

  static String getTimeDifference(DateTime scheduledDateTime) {
    Duration difference = scheduledDateTime.difference(DateTime.now());

    if (difference.inMinutes <= 0) {
      return "Alarm set for less than a minute from now";
    } else if (difference.inDays > 0) {
      if (difference.inHours % 24 == 0) {
        return "Alarm set for ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} and ${difference.inMinutes % 60} minute${difference.inMinutes % 60 > 1 ? 's' : ''} from now";
      } else {
        return "Alarm set for ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} and ${difference.inHours % 24} hour${difference.inHours % 24 > 1 ? 's' : ''} and ${difference.inMinutes % 60} minute${difference.inMinutes % 60 > 1 ? 's' : ''} from now";
      }
    } else if (difference.inHours > 0) {
      return "Alarm set for ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} and ${difference.inMinutes % 60} minute${difference.inMinutes % 60 > 1 ? 's' : ''} from now";
    } else {
      return "Alarm set for ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} from now";
    }
  }

  static void showAlarmSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16.0),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
