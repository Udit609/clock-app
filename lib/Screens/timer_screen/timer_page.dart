import 'package:alarm_clock/Screens/timer_screen/countdown_page.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:alarm_clock/utils/timer_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/data_list.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  String input = "000000";
  bool showCountdownPage = false;
  int duration = 0;

  void updateInput(String value) {
    setState(() {
      input = (input + value).padLeft(6, '0');
      input = input.substring(input.length - 6);
    });
  }

  void clearInput() {
    setState(() {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
        input = input.padLeft(6, '0');
      }
    });
  }

  void startCountdown() {
    setState(() {
      showCountdownPage = true;
      duration = TimerMethods.convertTimeToSeconds(input);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showCountdownPage) {
      return CountdownPage(
        onClose: () {
          setState(() {
            showCountdownPage = false;
          });
        }, duration: duration,
      );
    }

    bool inputIsNotEmpty = input != '000000';
    Color hrColor =
        input.substring(0, 2) != "00" ? Colors.white : Colors.white60;
    Color minColor =
        input.substring(2, 4) != "00" ? Colors.white : Colors.white60;
    Color secColor =
        input.substring(4, 6) != "00" ? Colors.white : Colors.white60;

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (inputIsNotEmpty) ? startTimerFAB(context) : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          timerInputWidget(hrColor, minColor, secColor),
          const SizedBox(height: 30),
          numberPad(),
        ],
      ),
    );
  }

  RichText timerInputWidget(Color hrColor, Color minColor, Color secColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: input.substring(0, 2),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: hrColor,
            ),
          ),
          TextSpan(
            text: "h    ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          TextSpan(
            text: input.substring(2, 4),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: minColor,
            ),
          ),
          TextSpan(
            text: "m    ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          TextSpan(
            text: input.substring(4, 6),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: secColor,
            ),
          ),
          TextSpan(
            text: "s",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  GridView numberPad() {
    return GridView.builder(
      padding: EdgeInsets.all(20.0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: timerNumPad.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        if (timerNumPad[index] != timerNumPad.last) {
          return InkWell(
            customBorder: CircleBorder(),
            onTap: () {
              updateInput(timerNumPad[index]);
            },
            child: Container(
              height: 30.0,
              width: 30.0,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: CustomColors.clockBG.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  timerNumPad[index],
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          );
        } else {
          return InkWell(
            customBorder: CircleBorder(),
            onTap: () {
              clearInput();
            },
            child: Container(
              height: 30.0,
              width: 30.0,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: CustomColors.clockBG.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.backspace_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Padding startTimerFAB(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: SizedBox(
        width: 76.0,
        height: 76.0,
        child: FittedBox(
            child: FloatingActionButton(
          onPressed: (){
            startCountdown();
            setState(() {
              input = "000000";
            });
          },
          backgroundColor: CustomColors.fabColor,
          shape: CircleBorder(),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 32.0,
          ),
        )),
      ),
    );
  }
}
