import 'package:alarm_clock/helpers/notification_controller.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FullscreenAlarmNotification extends StatefulWidget {
  final String title;
  final DateTime dateTime;
  final int notificationId;
  const FullscreenAlarmNotification({
    super.key,
    required this.title,
    required this.dateTime,
    required this.notificationId,
  });

  @override
  State<FullscreenAlarmNotification> createState() => _FullscreenAlarmNotificationState();
}

class _FullscreenAlarmNotificationState extends State<FullscreenAlarmNotification> {
  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(widget.dateTime);
    String formattedDate = DateFormat('EEEE, d MMM').format(widget.dateTime);
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm,
                size: 48.0,
                color: Colors.white,
              ),
              const SizedBox(
                height: 30.0,
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 42.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              TextButton(
                onPressed: () async {
                  await AwesomeNotifications().dismiss(widget.notificationId);
                  await NotificationController.updateAlarmPendingStatus(
                    widget.notificationId,
                    false,
                  );
                  Navigator.of(context).pop();
                  SystemNavigator.pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
