class AlarmInfo {
  int? id;
  String? title;
  DateTime? alarmDateTime;
  bool? isPending;
  int? gradientColorIndex;
  int? notificationId;
  String? scheduledDays;

  AlarmInfo({
    this.id,
    this.title,
    this.alarmDateTime,
    this.isPending,
    this.gradientColorIndex,
    this.notificationId,
    this.scheduledDays,
  });

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
    id: json["id"],
    title: json["title"],
    alarmDateTime: DateTime.parse(json["alarmDateTime"]),
    isPending: json["isPending"] == 1,
    gradientColorIndex: json["gradientColorIndex"],
    notificationId: json["notificationId"],
    scheduledDays: json['scheduledDays'],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "alarmDateTime": alarmDateTime!.toIso8601String(),
    "isPending": isPending == true ? 1 : 0,
    "gradientColorIndex": gradientColorIndex,
    "notificationId": notificationId,
    "scheduledDays": scheduledDays,
  };

  String mapToString(Map<int, int> map) {
    return map.entries.map((entry) => "${entry.key}:${entry.value}").join(",");
  }

  Map<int, int> stringToMap(String str) {
    return Map.fromEntries(
      str.split(",").map((entry) {
        var split = entry.split(":");
        return MapEntry(int.parse(split[0]), int.parse(split[1]));
      }),
    );
  }

  Map<int, int> getSelectedDaysMap() {
    if (scheduledDays != null && scheduledDays!.isNotEmpty) {
      return stringToMap(scheduledDays!);
    }
    return {};
  }

  void setSelectedDaysMap(Map<int, int> selectedDaysMap) {
    scheduledDays = mapToString(selectedDaysMap);
  }
}
