import 'dart:math';
import 'package:alarm_clock/helpers/alarm_helper.dart';
import 'package:alarm_clock/helpers/notification_helper.dart';
import 'package:alarm_clock/utils/alarm_methods.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/alarm_info.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  AlarmHelper alarmHelper = AlarmHelper();
  int? lastGradientColorIndex;

  void scheduleAlarm(DateTime dateTime) async {
    int gradientColorIndex;
    int notificationId = await generateUniqueNotificationId();

    do {
      gradientColorIndex =
          Random().nextInt(GradientTemplate.gradientTemplate.length);
    } while (gradientColorIndex == lastGradientColorIndex);
    lastGradientColorIndex = gradientColorIndex;

    var alarmInfo = AlarmInfo(
      title: 'Label',
      alarmDateTime: dateTime,
      isPending: true,
      gradientColorIndex: gradientColorIndex,
      notificationId: notificationId,
    );

    await alarmHelper.insertAlarm(alarmInfo);
    await scheduleAlarmNotification(
        notificationId, dateTime, 'Alarm', dateTime.weekday);

    String timeDifference = AlarmMethods.getTimeDifference(dateTime);
     AlarmMethods.showAlarmSnackBar(context, timeDifference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Alarm',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
      ),
      floatingActionButton: addAlarmFAB(context),
      body: alarmStream(context),
    );
  }

  StreamBuilder alarmStream(BuildContext context) {
    return StreamBuilder<List<AlarmInfo>>(
      stream: alarmHelper.watchAlarms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4.0,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text(
            'No alarm set!',
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w700),
          ));
        } else {
          return _buildAlarmList(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlarmList(BuildContext context, List<AlarmInfo> data) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var alarm = data[index];
          var gradientColors = GradientTemplate
              .gradientTemplate[alarm.gradientColorIndex ?? 0].colors;

          return Container(
            margin: index == data.length - 1
                ? const EdgeInsets.only(bottom: 80)
                : const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    await AlarmMethods.updateTitleDialog(context, alarm);
                    setState(() {});
                  },
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.label,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alarm.title ?? 'Label',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'avenir',
                        ),
                      ),
                      const Spacer(),
                      alarmSwitch(alarm),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await AlarmMethods.weekdaySelectionDialog(context, alarm);
                  },
                  child: Text(
                    AlarmMethods.getAlarmStatus(alarm),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'avenir',
                    ),
                  ),
                ),
                timeAndDeleteButton(context, alarm),
              ],
            ),
          );
        },
      ),
    );
  }

  Switch alarmSwitch(AlarmInfo alarm) {
    return Switch(
      onChanged: (bool value) async {
        setState(() {
          alarm.isPending = value;
        });

        if (value) {
          if (alarm.scheduledDays != null && alarm.scheduledDays!.isNotEmpty) {
            Map<int, int> scheduledDaysMap = alarm.getSelectedDaysMap();

            for (var entry in scheduledDaysMap.entries) {
              int dayIndex = entry.key;
              int notificationId = entry.value;

              await scheduleAlarmNotification(
                notificationId,
                alarm.alarmDateTime!,
                alarm.title!,
                dayIndex,
                repeat: true,
              );
            }
            DateTime nextAlarmDate = AlarmMethods.getNextAlarmDate(
                scheduledDaysMap, alarm.alarmDateTime!);
            String timeDifference =
                AlarmMethods.getTimeDifference(nextAlarmDate);
            AlarmMethods.showAlarmSnackBar(context, timeDifference);
          } else {
            if (DateTime.now().isAfter(alarm.alarmDateTime ?? DateTime.now())) {
              alarm.alarmDateTime = alarm.alarmDateTime!.add(const Duration(days: 1));
              await alarmHelper.updateAlarm(alarm);
            }
            await scheduleAlarmNotification(
              alarm.notificationId!,
              alarm.alarmDateTime!,
              alarm.title!,
              alarm.alarmDateTime!.weekday,
            );

            String timeDifference =
                AlarmMethods.getTimeDifference(alarm.alarmDateTime!);
            AlarmMethods.showAlarmSnackBar(context, timeDifference);
          }
        } else {
          if (alarm.scheduledDays != null && alarm.scheduledDays!.isNotEmpty) {
            Map<int, int> scheduledDaysMap = alarm.getSelectedDaysMap();

            for (var notificationId in scheduledDaysMap.values) {
              await cancelScheduledNotifications(notificationId);
            }
          } else {
            await cancelScheduledNotifications(alarm.notificationId!);
          }
        }

        await alarmHelper.updateAlarm(alarm);
      },
      value: alarm.isPending ?? true,
      activeColor: Colors.white,
    );
  }

  Row timeAndDeleteButton(BuildContext context,AlarmInfo alarm){
    final String formattedTime =
    DateFormat('HH:mm').format(alarm.alarmDateTime ?? DateTime.now());
    return Row(
      children: <Widget>[
        AlarmMethods.timePickerTheme(
          context,
          Builder(builder: (context) {
            return GestureDetector(
              onTap: () async {
                DateTime? newDateTime =
                await AlarmMethods.customTimePicker(
                  context,
                  alarm.alarmDateTime!,
                );

                if (newDateTime != null) {
                  alarm.alarmDateTime = newDateTime;
                  alarm.isPending = true;
                  await alarmHelper.updateAlarm(alarm);

                  Map<int, int> selectedDaysMap =
                  alarm.getSelectedDaysMap();
                  if (selectedDaysMap.isEmpty) {
                    await cancelScheduledNotifications(
                        alarm.notificationId!);
                    if (DateTime.now().isAfter(newDateTime)) {
                      newDateTime =
                          newDateTime.add(const Duration(days: 1));
                      alarm.alarmDateTime = newDateTime;
                      await alarmHelper.updateAlarm(alarm);
                    }
                    await scheduleAlarmNotification(
                      alarm.notificationId!,
                      newDateTime,
                      alarm.title!,
                      newDateTime.weekday,
                    );
                    String timeDifference =
                    AlarmMethods.getTimeDifference(
                        alarm.alarmDateTime!);
                    AlarmMethods.showAlarmSnackBar(
                        context, timeDifference);
                  } else {
                    rescheduleNotificationsForSelectedDays(alarm);

                    DateTime nextAlarmDate =
                    AlarmMethods.getNextAlarmDate(
                        selectedDaysMap, alarm.alarmDateTime!);
                    String timeDifference =
                    AlarmMethods.getTimeDifference(
                        nextAlarmDate);
                    AlarmMethods.showAlarmSnackBar(
                      context,
                      timeDifference,
                    );
                  }
                  setState(() {});
                }
              },
              child: Text(
                formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'avenir',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.delete),
          iconSize: 28.0,
          color: Colors.white,
          onPressed: () async {
            await alarmHelper.deleteAlarm(alarm.id ?? 0);
          },
        ),
      ],
    );
  }

  SizedBox addAlarmFAB(BuildContext context) {
    return SizedBox(
      width: 76.0,
      height: 76.0,
      child: FittedBox(
        child: AlarmMethods.timePickerTheme(
          context,
          Builder(builder: (context) {
            return FloatingActionButton(
              onPressed: () async {
                DateTime? selectedDateTime =
                    await AlarmMethods.customTimePicker(
                  context,
                  DateTime.now().add(const Duration(hours: 1)),
                );
                if (selectedDateTime != null) {
                  if (DateTime.now().isAfter(selectedDateTime)) {
                    selectedDateTime = selectedDateTime.add(const Duration(days: 1));
                  }
                  scheduleAlarm(selectedDateTime);
                }
              },
              backgroundColor: CustomColors.fabColor,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_alarm,
                color: Colors.white,
                size: 32.0,
              ),
            );
          }),
        ),
      ),
    );
  }
}
