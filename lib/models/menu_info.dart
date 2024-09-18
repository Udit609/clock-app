import 'package:flutter/foundation.dart';

enum MenuType { clock, alarm}

class MenuInfo extends ChangeNotifier{
  MenuType menuType;
  String? title;
  String? imageSource;

  MenuInfo({this.title, this.imageSource, required this.menuType});

  updateMenu(MenuInfo menuInfo) {
    menuType = menuInfo.menuType;
    title = menuInfo.title;
    imageSource = menuInfo.imageSource;

    notifyListeners();
  }

}

List<MenuInfo> menuItems = [
  MenuInfo(
      menuType: MenuType.clock,
      title: 'Clock',
      imageSource: 'assets/clock_icon.png'),
  MenuInfo(
      menuType: MenuType.alarm,
      title: 'Alarm',
      imageSource: 'assets/alarm_icon.png'),
];