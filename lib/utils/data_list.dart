import 'package:alarm_clock/utils/enums.dart';
import '../models/menu_info.dart';

List<MenuInfo> menuItems = [
  MenuInfo(
      menuType: MenuType.clock,
      title: 'Clock',
      imageSource: 'assets/clock_icon.png'),
  MenuInfo(
      menuType: MenuType.alarm,
      title: 'Alarm',
      imageSource: 'assets/alarm_icon.png'),
  MenuInfo(
      menuType: MenuType.timer,
      title: 'Timer',
      imageSource: 'assets/timer_icon.png'),
  MenuInfo(
      menuType: MenuType.stopwatch,
      title: 'Stopwatch',
      imageSource: 'assets/stopwatch_icon.png'),
];

List<String> timerNumPad = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '00',
  '0',
  'cancel'
];
