import 'package:alarm_clock/models/menu_info.dart';
import 'package:alarm_clock/utils/colors.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'Screens/home_page.dart';
import 'package:provider/provider.dart';
import 'helpers/notification_controller.dart';

void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: 'Notification channel for basic tests',
      ),
      NotificationChannel(
        channelKey: 'scheduled',
        channelName: 'Alarm',
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: CustomColors.clockBG,
        importance: NotificationImportance.High,
        channelDescription: 'Notification channel to schedule alarms',
        playSound: true,
        locked: true,
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        enableVibration: true,
      ),
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: MyApp.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'avenir',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider<MenuInfo>(
          create: (BuildContext context) => MenuInfo(menuType: MenuType.clock),
          child: const HomePage()),
    );
  }
}
