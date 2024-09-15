import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'colors.dart';

class TimerMethods {
  static int convertTimeToSeconds(String? time) {
    if (time == null || time.isEmpty) return 0;

    if (time.contains(':')) {
      List<String> timeParts = time.split(':');
      int seconds = 0;

      if (timeParts.length == 3) {
        // HH:MM:SS
        int hours = int.parse(timeParts[0]);
        int minutes = int.parse(timeParts[1]);
        int sec = int.parse(timeParts[2]);
        seconds = (hours * 3600) + (minutes * 60) + sec;
      } else if (timeParts.length == 2) {
        // MM:SS
        int minutes = int.parse(timeParts[0]);
        int sec = int.parse(timeParts[1]);
        seconds = (minutes * 60) + sec;
      }

      return seconds;
    } else if (time.length == 6) {
      //Input String
      int hours = int.parse(time.substring(0, 2));
      int minutes = int.parse(time.substring(2, 4));
      int seconds = int.parse(time.substring(4, 6));

      return (hours * 3600) + (minutes * 60) + seconds;
    }

    return int.parse(time);
  }

  static CircularCountDownTimer countDownTimer({
    required BuildContext context,
    required CountDownController countDownController,
    required int duration,
    void Function()? onComplete,
    void Function()? onStart,
  }) {
    return CircularCountDownTimer(
      controller: countDownController,
      width: MediaQuery.of(context).size.width / 2.3,
      height: MediaQuery.of(context).size.width / 2.3,
      duration: duration,
      strokeWidth: 8.0,
      strokeCap: StrokeCap.round,
      isReverse: true,
      isReverseAnimation: true,
      fillColor: CustomColors.minHandStatColor,
      ringColor: CustomColors.pageBackgroundColor.withOpacity(0.8),
      textStyle: TextStyle(
        fontSize: 32.0,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      onStart: onStart,
      onComplete: onComplete,
    );
  }
}
