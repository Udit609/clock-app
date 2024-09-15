import 'package:alarm_clock/utils/colors.dart';
import 'package:alarm_clock/utils/timer_methods.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CountdownPage extends StatefulWidget {
  final VoidCallback onClose;
  final int duration;
  const CountdownPage(
      {super.key, required this.onClose, required this.duration});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  final CountDownController countDownController = CountDownController();
  int newDuration = 0;
  bool isComplete = false;
  bool isReset = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Timer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            extendedTimerCard(context, countDownController, widget.duration),
          ],
        ),
      ),
    );
  }

  Card extendedTimerCard(
    BuildContext context,
    CountDownController countDownController,
    int duration,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: isComplete
          ? CustomColors.hourHandStatColor
          : CustomColors.clockBG.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '1h Timer',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: widget.onClose,
                  customBorder: CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: CustomColors.menuBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: TimerMethods.countDownTimer(
                context: context,
                countDownController: countDownController,
                duration: duration,
                onComplete: () {
                  setState(() {
                    isComplete = true;
                  });
                  FlutterRingtonePlayer().play(
                    fromAsset: 'assets/sounds/timer_expired.mp3',
                    volume: 1.0,
                    looping: true,
                    asAlarm: true,
                  );
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            countdownTimerButtons(countDownController, duration, newDuration),
          ],
        ),
      ),
    );
  }

  Row countdownTimerButtons(
      CountDownController countDownController, int duration, int newDuration) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isReset
            ? Spacer()
            : Expanded(
                child: TextButton(
                  onPressed: () {
                    String? remainingTime = countDownController.getTime();
                    int remainingSeconds =
                        TimerMethods.convertTimeToSeconds(remainingTime);

                    newDuration = remainingSeconds + 60;
                    if (countDownController.isPaused.value) {
                      countDownController.restart(duration: newDuration);
                      countDownController.pause();
                    } else {
                      countDownController.restart(duration: newDuration);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        CustomColors.menuBackgroundColor.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 5.0,
                    ),
                    child: Text(
                      '+1:00',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                if (countDownController.isPaused.value) {
                  countDownController.resume();
                } else {
                  countDownController.pause();
                }
                if (isComplete) {
                isComplete = false;
                  isReset = true;
                  FlutterRingtonePlayer().stop();
                  countDownController.restart();
                  countDownController.pause();
                }
                if (countDownController.isResumed.value) {
                  isReset = false;
                }
              });
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  isComplete ? Colors.white : CustomColors.hourHandEndColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 3.0,
                horizontal: 5.0,
              ),
              child: isComplete
                  ? Icon(
                      Icons.stop,
                      size: 28.0,
                      color: CustomColors.menuBackgroundColor,
                    )
                  : countDownController.isPaused.value
                      ? Icon(
                          Icons.play_arrow,
                          size: 28.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.pause,
                          size: 28.0,
                          color: Colors.white,
                        ),
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        isReset
            ? Spacer()
            : InkWell(
                onTap: () {
                  setState(() {
                    if (!isReset) {
                      isReset = true;
                      countDownController.restart(duration: duration);
                      countDownController.pause();
                    }
                  });
                },
                child: Icon(
                  Icons.restart_alt,
                  color: CustomColors.secHandColor,
                  size: 30.0,
                ),
              ),
      ],
    );
  }
}
