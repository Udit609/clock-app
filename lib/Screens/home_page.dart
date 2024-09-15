import 'package:alarm_clock/Screens/alarm_screen/alarm_page.dart';
import 'package:alarm_clock/Screens/clock_page.dart';
import 'package:alarm_clock/Screens/timer_screen/timer_page.dart';
import 'package:alarm_clock/models/menu_info.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:alarm_clock/utils/enums.dart';
import 'package:alarm_clock/utils/data_list.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<bool> requestPreciseAlarm() async {
    final PermissionStatus status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      return false;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );
    requestPreciseAlarm().then((onValue) {
      if (!onValue) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: CustomColors.clockBG,
            content: Text(
              'Allow Clock App to set precise alarms',style: TextStyle(fontSize: 16.0,color: Colors.white),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Don\'t Allow',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed: () {
                  Permission.scheduleExactAlarm.request().then((_) => Navigator.pop(context));
                },
                child: Text(
                  'Allow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuItems.map((e) => menuButton(context, e)).toList(),
          ),
          VerticalDivider(
            color: Colors.white10,
            width: 10.0,
          ),
          Expanded(
            child: Consumer(
              builder: (BuildContext context, MenuInfo value, Widget? child) {
                if (value.menuType == MenuType.clock) {
                  return ClockPage();
                } else if (value.menuType == MenuType.alarm) {
                  return AlarmPage();
                }else if (value.menuType == MenuType.timer) {
                  return TimerPage();
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Consumer menuButton(BuildContext context, MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
        builder: (context, MenuInfo value, Widget? child) {
      return TextButton(
        onPressed: () {
          var menuInfo = Provider.of<MenuInfo>(context, listen: false);
          menuInfo.updateMenu(currentMenuInfo);
        },
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(32.0)),
            ),
            backgroundColor: currentMenuInfo.menuType == value.menuType
                ? CustomColors.menuBackgroundColor
                : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16.0)),
        child: Column(
          children: [
            Image.asset(
              currentMenuInfo.imageSource ?? '',
              scale: 1.5,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              currentMenuInfo.title ?? '',
              style: TextStyle(
                fontFamily: 'avenir',
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }
}
