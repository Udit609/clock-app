import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';  // Import for StreamController
import '../models/alarm_info.dart';
import 'notification_helper.dart';

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnDateTime = 'alarmDateTime';
const String columnPending = 'isPending';
const String columnColorIndex = 'gradientColorIndex';
const String columnNotificationId = 'notificationId';
const String columnScheduledDays = 'scheduledDays ';

class AlarmHelper {
  static final AlarmHelper _instance = AlarmHelper._internal();
  Database? _database;

  final StreamController<List<AlarmInfo>> _alarmStreamController = StreamController.broadcast();

  factory AlarmHelper() {
    return _instance;
  }

  AlarmHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'alarm.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAlarm (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDateTime TEXT NOT NULL,
        $columnPending INTEGER,
        $columnColorIndex INTEGER,
        $columnNotificationId INTEGER UNIQUE,
        $columnScheduledDays TEXT
      )
    ''');
  }

  // Insert
  Future<void> insertAlarm(AlarmInfo alarmInfo) async {
    final db = await database;
    await db.insert(tableAlarm, alarmInfo.toMap());
    _refreshAlarms();
  }

  // Read (all alarms)
  Future<List<AlarmInfo>> getAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableAlarm);
    return List.generate(maps.length, (i) {
      return AlarmInfo.fromMap(maps[i]);
    });
  }

  // Update
  Future<int> updateAlarm(AlarmInfo alarmInfo) async {
    final db = await database;
    final result = await db.update(
      tableAlarm,
      alarmInfo.toMap(),
      where: '$columnId = ?',
      whereArgs: [alarmInfo.id],
    );
    _refreshAlarms();
    return result;
  }

  // Delete
  Future<int> deleteAlarm(int id) async {
    final db = await database;
    final result = await db.query(
      tableAlarm,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final notificationId = result.first['notificationId'] as int?;
      final scheduledDays = result.first['scheduledDays'] as String?;
      final isPending = result.first['isPending'] as int?;

      if (scheduledDays != null && scheduledDays.isNotEmpty) {
        final scheduledDaysMap = AlarmInfo().stringToMap(scheduledDays);

        for (var notificationId in scheduledDaysMap.values) {
          await cancelScheduledNotifications(notificationId);
        }
      }

      else if (isPending == 1) {
        await cancelScheduledNotifications(notificationId ?? 0);
      }
    }
    final deleteResult = await db.delete(
      tableAlarm,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    _refreshAlarms();
    return deleteResult;
  }

  Future<bool> notificationIdExists(int notificationId) async {
    final db = await database;
    final result = await db.query(
      tableAlarm,
      where: '$columnNotificationId = ?',
      whereArgs: [notificationId],
    );
    return result.isNotEmpty;
  }

  Stream<List<AlarmInfo>> watchAlarms() {
    _refreshAlarms();
    return _alarmStreamController.stream;
  }

  Future<void> _refreshAlarms() async {
    final alarms = await getAlarms();
    _alarmStreamController.add(alarms);
  }

  void dispose() {
    _alarmStreamController.close();
  }
}
