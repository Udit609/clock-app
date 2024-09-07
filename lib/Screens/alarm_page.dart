import 'dart:math';
import 'package:alarm_clock/helpers/alarm_helper.dart';
import 'package:alarm_clock/helpers/notification_helper.dart';
import 'package:alarm_clock/utils/alarm_methods.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm_info.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      floatingActionButton: addAlarmFAB(context),
      body: alarmStream(context),
    );
  }

  StreamBuilder alarmStream(BuildContext context) {
    return StreamBuilder<List<AlarmInfo>>(
      stream: alarmHelper.watchAlarms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4.0,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
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
          final String formattedTime =
              DateFormat('HH:mm').format(alarm.alarmDateTime ?? DateTime.now());

          return Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
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
                      Icon(
                        Icons.label,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        alarm.title ?? 'Label',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'avenir',
                        ),
                      ),
                      Spacer(),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'avenir',
                    ),
                  ),
                ),
                Row(
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
                                      newDateTime.add(Duration(days: 1));
                                  alarm.alarmDateTime = newDateTime;
                                  await alarmHelper.updateAlarm(alarm);
                                }
                                await scheduleAlarmNotification(
                                  alarm.notificationId!,
                                  newDateTime,
                                  alarm.title!,
                                  newDateTime.weekday,
                                );
                              } else {
                                rescheduleNotificationsForSelectedDays(alarm);
                              }
                              setState(() {});
                            }
                          },
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'avenir',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete),
                      iconSize: 28.0,
                      color: Colors.white,
                      onPressed: () async {
                        await alarmHelper.deleteAlarm(alarm.id ?? 0);
                      },
                    ),
                  ],
                ),
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
          } else {
            if (DateTime.now().isAfter(alarm.alarmDateTime ?? DateTime.now())) {
              alarm.alarmDateTime = alarm.alarmDateTime!.add(Duration(days: 1));
              await alarmHelper.updateAlarm(alarm);
            }
            await scheduleAlarmNotification(
              alarm.notificationId!,
              alarm.alarmDateTime!,
              alarm.title!,
              alarm.alarmDateTime!.weekday,
            );
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
                  DateTime.now().add(Duration(hours: 1)),
                );
                if (selectedDateTime != null) {
                  if (DateTime.now().isAfter(selectedDateTime)) {
                    selectedDateTime = selectedDateTime.add(Duration(days: 1));
                  }
                  scheduleAlarm(selectedDateTime);
                }
              },
              backgroundColor: CustomColors.minHandStatColor,
              shape: CircleBorder(),
              child: Icon(
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
