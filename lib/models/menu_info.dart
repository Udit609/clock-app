import 'package:alarm_clock/utils/enums.dart';
import 'package:flutter/foundation.dart';

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